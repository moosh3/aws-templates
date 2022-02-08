do you have a solution to:
- Detect brute force attack on your servers?
- Identifying when someone makes changes to critical files?
- Identify if server are sending traffic to unexpected locations?
- Identify if someone is trying web application based attacks?
- Track on what exactly users are doing within your network?
- Identify when someone is scanning your network?

incident response plan has several steps:

- Preparation
- Detection
- Containment
- Investigation
- Recovery
- Lessons Learned

ensure logging is enabled with the help of cloudtrail, vpc flowlogs, ec2 instances
use aws organizations to separate accounts to reduce blast radius

# Detection Phase
- If you do not know that something is going wrong, you will not be able to respond to it
- Use behavioral based rules by identifying or detecting breaches

Sample steps during this phase:
- Lots of AWS Console sign-in failures in the past hour
- If a user is logging in at 3AM in the morning and launching news servers
- splunk does that

# Containment Phase
Once we have identified that an incident has occurred, prefer to use some kind of automatation to help you contain the resource

Use AWS CLI or SDK's for quick containment using predefined security groups

# Investigation Phase

Once the server is isolated, determine and analyze logs as well as timelines

Sample steps during this phase:

- Use cloudwatch


# Allowed Services for hacking


https://docs.google.com/document/d/11_1lNSNMI7tRTmfBR74FOkaQbDfVZPZ7u0H4tFXRrGs/edit
