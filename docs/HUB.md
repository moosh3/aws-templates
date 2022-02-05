- deploy central transit gateway(s)
- direct connect
- vpc endpoints
- dns resolver endpoints
- guard duty

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
