---
slug: geo-lab2-workshop
id: fqxvlied3xap
type: challenge
title: 'Elastic Geo Lab 2: Maps'
teaser: Learn about the Maps app in Kibana.
notes:
- type: text
  contents: |-
    ![logo-elastic-horizontal-color-reverse.png](../assets/logo-elastic-horizontal-color-reverse.png)


              Please be patient as we set up Lab 2.
tabs:
- id: tzkkux9rqj4u
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
"Where" is a critical question for many users of the Elastic Stack. Whether you're protecting your network from attackers, investigating slow application response times in specific locations, or simply hailing a ride home, geo data — and search — play an important role. The Maps app in Kibana gives you an intuitive way to weave geospatial layers in with your temporal, structured, text, and other Elasticsearch data so you can ask (and answer) meaningful questions.

Elastic Kibana Maps is a feature that allows users to visualize geographical data in Kibana. It enables the creation of maps with multiple layers and indices, allowing users to plot individual documents or use aggregations to plot any dataset, no matter how large.

In Lab 2 you will learn about how to use the Maps app in Kibana.  With Maps, you can:

- Build maps with multiple layers and indices.
- Animate spatial temporal data.
- Upload GeoJSON files and shapefiles.
- Embed your map in dashboards.
- Symbolize features using data values.
- Focus on only the data that’s important to you.

You can find documentation on Kibana Maps here: https://www.elastic.co/docs/explore-analyze/visualize/maps

## Maps Overview
===


## Conclusion
===
In lab 2 you learned about ...

Congratulations, you have completed Lab 2. Click the **Next** button to proceed to the next lab.