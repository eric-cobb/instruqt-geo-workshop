---
slug: geo-lab4-workshop
id: fknldrj1tup9
type: challenge
title: 'Elastic Geo Lab 4: Machine Learning Anomalies [PLACEHOLDER]'
teaser: 'Machine Learning Anomalies: Learn about geospatial Machine Learning anomalies.'
notes:
- type: text
  contents: |-
    ![logo-elastic-horizontal-color-reverse.png](../assets/logo-elastic-horizontal-color-reverse.png)


              Please be patient as we set up Lab 4.
tabs:
- id: 5uqtjo5clkpp
  title: Kibana
  type: service
  hostname: kubernetes-vm
  path: /app/discover#/?_g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:now-48h,to:now))&_a=(columns:!(),dataSource:(dataViewId:trimet-geo-workshop-data,type:dataView),filters:!(),interval:auto,query:(language:kuery,query:''),sort:!(!('@timestamp',desc)))
  port: 30001
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
- id: ectvi6yacvvz
  title: Terminal
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
