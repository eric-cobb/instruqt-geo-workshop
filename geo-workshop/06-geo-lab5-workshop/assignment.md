---
slug: geo-lab5-workshop
id: egxuiyqry1p4
type: challenge
title: 'Elastic Geo Lab 5: Ingest Pipelines [PLACEHOLDER]'
teaser: Learn about Elasticsearch ingest pipelines.
notes:
- type: text
  contents: |-
    ![logo-elastic-horizontal-color-reverse.png](../assets/logo-elastic-horizontal-color-reverse.png)


              Please be patient as we set up Lab 5.
tabs:
- id: l7ktjr5kfe2p
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
difficulty: ""
timelimit: 600
enhanced_loading: null
---
In Lab 5 you will learn about ...

## Section
===

## Conclusion
===
In lab 5 you learned about ...

Congratulations, you have completed Lab 5. Click the **Next** button to proceed to the next lab.
