import boto3

dynamodb = boto3.resource('dynamodb', region_name='ca-central-1')
table = dynamodb.Table('machine-metrics')

INSTANCE_IDS = [
    "i-0e5e3a90ce6121dd0",
    "i-0c6f72c8c9982b572",
    "i-09d1721940afdb952",
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

        if recent_avg > previous_avg + 1.0:
            status = "RISING"
        else:
            status = "stable"

        results[instance_id] = f"{status} (recent avg {recent_avg:.2f}, previous avg {previous_avg:.2f})"

    for instance_id, result in results.items():
        print(instance_id, result)
