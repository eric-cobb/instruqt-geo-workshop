---
slug: geo-lab3-workshop
id: ieowvncr5xsm
type: challenge
title: 'Elastic Geo Lab 3: Dashboards [PLACEHOLDER]'
teaser: Learn about Dashboards app in Kibana.
notes:
- type: text
  contents: Please be patient as we set up the the lab 3 challenge.
tabs:
- id: 3uclsq1oio4q
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
In Lab 3 you will learn about ...

## Section
===

## Conclusion
===
In lab 3 you learned about ...

Congratulations, you have completed Lab 3. Click the **Next** button to proceed to the next lab.