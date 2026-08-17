resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "datacenter-power-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "CPU Utilization (%)"
          region = "ca-central-1"
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-02b9adfa5a508b07f"],
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-0e1393dc717d2c144"],
            ["AWS/EC2", "CPUUtilization", "InstanceId", "i-0b5dd9a5de7c53afc"]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Simulated Temperature"
          region = "ca-central-1"
          metrics = [
            ["DatacenterSim", "SimulatedTemperature", "InstanceId", "i-02b9adfa5a508b07f"],
            ["DatacenterSim", "SimulatedTemperature", "InstanceId", "i-0e1393dc717d2c144"],
            ["DatacenterSim", "SimulatedTemperature", "InstanceId", "i-0b5dd9a5de7c53afc"]
          ]
          period = 300
          stat   = "Average"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          title  = "Target Group Healthy Host Count"
          region = "ca-central-1"
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "TargetGroup", "targetgroup/datacenter-web-tg/a0b081e8f256133c", "LoadBalancer", "app/datacenter-web-alb/721ef26a5948d7bc"]
          ]
          period = 60
          stat   = "Average"
        }
      }
    ]
  })
}
