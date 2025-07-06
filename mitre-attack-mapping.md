# Incident Report – S3 Data Exfiltration (T1530)

## Summary
Simulated exfiltration of data from a public S3 bucket...

## MITRE Technique
- ID: T1530
- Name: Data from Cloud Storage

## Timeline
- 13:02 UTC – S3 bucket made public
- 13:05 UTC – Mass `GetObject` logged in CloudTrail
...

## Detection
- GuardDuty finding ID: ...
- CloudTrail: `GetObject` by unknown IP

## Response
- S3 policy updated
- Public access blocked
