---
slug: geo-lab4-workshop
id: fknldrj1tup9
type: challenge
title: 'Elastic Geo Lab 6: Machine Learning Anomalies [PLACEHOLDER]'
teaser: 'Machine Learning Anomalies: Learn about geospatial Machine Learning anomalies.'
notes:
- type: text
  contents: Please be patient as we set up the the lab 4 challenge.
tabs:
- id: 5uqtjo5clkpp
  title: Kibana
  type: service
  hostname: kubernetes-vm
  path: /app/discover#/view/fb5396f0-4c2e-11ee-a369-9fe9cf70b370?_g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:now-2y,to:now))
  port: 30001
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
- id: hldqydtehg4k
  title: host
  type: terminal
  hostname: kubernetes-vm
difficulty: ""
timelimit: 600
enhanced_loading: null
---
In Lab 4 you will learn about ...

## Section
===

## Conclusion
===
In lab 4 you learned about ...

Congratulations, you have completed Lab 5. Click the **Next** button to proceed to the next lab.
