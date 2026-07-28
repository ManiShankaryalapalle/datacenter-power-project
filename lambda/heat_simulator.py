import boto3,random
from datetime import datetime, timedelta

cloudwatch = boto3.client('cloudwatch', region_name='ca-central-1')

INSTANCE_IDS = [
    "i-0e5e3a90ce6121dd0",
    "i-0c6f72c8c9982b572",
    "i-09d1721940afdb952",
]

def lambda_handler(event, context):
    end_time = datetime.utcnow()
    start_time = end_time - timedelta(minutes=10)

    for instance_id in INSTANCE_IDS:
        response = cloudwatch.get_metric_statistics(
            Namespace='AWS/EC2',
            MetricName='CPUUtilization',
            Dimensions=[
                {'Name': 'InstanceId', 'Value': instance_id}
            ],
            StartTime=start_time,
            EndTime=end_time,
            Period=300,
            Statistics=['Average']
        )

        datapoints = response['Datapoints']
        if datapoints:
            cpu = datapoints[0]['Average']
        else:
            cpu = 0.0

        baseline_temp = 35.0
        temp = baseline_temp + (cpu * 0.6) + random.uniform(-1, 1)

        cloudwatch.put_metric_data(
            Namespace='DatacenterSim',
            MetricData=[
                {
                    'MetricName': 'SimulatedTemperature',
                    'Dimensions': [
                        {'Name': 'InstanceId', 'Value': instance_id}
                    ],
                    'Value': temp,
                    'Unit': 'None'
                }
            ]
        )

        print(instance_id, round(cpu, 2), round(temp, 2))
