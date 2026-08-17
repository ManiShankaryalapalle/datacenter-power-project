import boto3
TARGET_GROUP_ARN = "arn:aws:elasticloadbalancing:ca-central-1:165742852875:targetgroup/datacenter-web-tg/a0b081e8f256133c"
SNS_TOPIC_ARN = "arn:aws:sns:ca-central-1:165742852875:load-balancer-alerts"

elbv2 = boto3.client('elbv2', region_name='ca-central-1')
sns = boto3.client('sns', region_name='ca-central-1')
dynamodb = boto3.resource('dynamodb', region_name='ca-central-1')
table = dynamodb.Table('machine-metrics')

INSTANCE_IDS = [
    "i-02b9adfa5a508b07f",
    "i-0e1393dc717d2c144",
    "i-0b5dd9a5de7c53afc",
]

def lambda_handler(event, context):
    results = {}

    for instance_id in INSTANCE_IDS:
        response = table.query(
            KeyConditionExpression=boto3.dynamodb.conditions.Key('instance_id').eq(instance_id),
            ScanIndexForward=True
        )

        items = response['Items']
        temps = [float(item['temperature']) for item in items]

        if len(temps) < 6:
            results[instance_id] = "not enough data yet"
            continue

        recent = temps[-3:]
        previous = temps[-6:-3]

        recent_avg = sum(recent) / len(recent)
        previous_avg = sum(previous) / len(previous)

        if recent_avg > previous_avg + 3.0:
            status = "RISING"
        else:
            status = "stable"

        results[instance_id] = f"{status} (recent avg {recent_avg:.2f}, previous avg {previous_avg:.2f})"

    for instance_id, result in results.items():
        print(instance_id, result)
        if "RISING" in result:
            try:
                elbv2.deregister_targets(
                    TargetGroupArn=TARGET_GROUP_ARN,
                    Targets=[{'Id': instance_id, 'Port': 80}]
                )
                print(f"  -> deregistered {instance_id} from load balancer")
                sns.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject="Load Alert: Instance Deregistered",
                    Message=f"{instance_id} is trending toward overload and was removed from the load balancer.\n\n{result}"
                )
                print(f"  -> alert sent for {instance_id}")
            except Exception as e:
                print(f"  -> deregister failed for {instance_id}: {e}")
        elif "stable" in result:
            try:
                elbv2.register_targets(
                    TargetGroupArn=TARGET_GROUP_ARN,
                    Targets=[{'Id': instance_id, 'Port': 80}]
                )
                print(f"  -> ensured {instance_id} is registered")
            except Exception as e:
                print(f"  -> register failed for {instance_id}: {e}")
