resource "aws_iot_thing" "IotSensorThing" {
  name = "IotSensorThing"

  attributes = {
    First = "AttributeAValue"
  }
}
