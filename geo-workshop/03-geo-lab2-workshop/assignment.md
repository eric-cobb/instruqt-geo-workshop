---
slug: geo-lab2-workshop
id: fqxvlied3xap
type: challenge
title: 'Elastic Geo Lab 2: Maps [PLACEHOLDER]'
teaser: Learn about the Maps app in Kibana.
notes:
- type: text
  contents: Please be patient as we set up the the lab 2 challenge.
tabs:
- id: tzkkux9rqj4u
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
difficulty: ""
timelimit: 600
enhanced_loading: null
---
In Lab 2 you will learn about ...

## Section
===

## Conclusion
===
In lab 2 you learned about ...

Congratulations, you have completed Lab 2. Click the **Next** button to proceed to the next lab.