import aws_cdk as core
import aws_cdk.assertions as assertions

from task1.task1_stack import Task1Stack

# example tests. To run these tests, uncomment this file along with the example
# resource in task1/task1_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = Task1Stack(app, "task1")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
