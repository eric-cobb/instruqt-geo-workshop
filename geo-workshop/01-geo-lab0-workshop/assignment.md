---
slug: geo-lab0-workshop
id: izsp6wyayyxe
type: challenge
title: 'Elastic Geo Lab 0: Workshop Lab Overview'
teaser: Welcome to the Elastic Geospatial Workshop.  In this lab, you will receive
  an overview of the workshop lab and content.
notes:
- type: text
  contents: |-
    ![logo-elastic-horizontal-color-reverse.png](../assets/logo-elastic-horizontal-color-reverse.png)


               Please be patient as we set up Lab 0.
tabs:
- id: shexkvfxkaxa
  title: Kibana
  type: service
  hostname: kubernetes-vm
  path: /app/discover#/?_g=(filters:!(),refreshInterval:(pause:!t,value:60000),time:(from:now-24h%2Fh,to:now))
  port: 30001
  custom_request_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
  custom_response_headers:
  - key: Content-Security-Policy
    value: 'script-src ''self''; worker-src blob: ''self''; style-src ''unsafe-inline''
      ''self'''
- id: zdtpvrfnkmxi
  title: host-vm
  type: terminal
  hostname: host-vm
difficulty: ""
timelimit: 600
enhanced_loading: null
---
We're excited to have you join us today for the lab portion of the Elasticsearch Geospatial workshop. Whether you're a seasoned data professional or just beginning your data analysis journey, this workshop is designed to give you exposure and knowledge to use Elasticsearch's geospatial capabilities for your data analysis and investigation needs.

Our goal is for you to feel comfortable and confident using Elasticsearch Geospatial features for your data analysis tasks. We want you to leave with a sense of achievement and new skills to apply in your projects.

We hope you enjoy the Elasticsearch Geospatial Workshop Lab.

## What to Expect
===

Throughout the workshop you will see **Hints** or **Answers** like the below:
<details>
	<summary>Hint</summary>
<img src="../assets/switch-s.png" alt="Devtools switch" />
</details>
You can click on these for help.

- Experience: You should have some basic knowledge of Elasticearch and Kibana.
- Lecture: This lab is intended to be accompanied by a lecture discussing an overview of Elastic and Elasticsearch Geospatial features.
- Hands-On Experience: You will have access to Kibana via a tab in the Instruqt lab environment where you will be able to conduct hands-on exercises.
- Total Workshop time: 2-3 Hours

## Lab  List
===

- Elastic Geo Lab 1: Discover: Learn about the Discover app in Kibana.
- Elastic Geo Lab 2: Maps: Learn about the Maps app in Kibana.
- Elastic Geo Lab 3: Dashboards: Learn about Dashboards in Kibana.
- Elastic Geo Lab 4: Machine Learning Anomalies: Learn about geospatial Machine Learning anomalies.
- Elastic Geo Lab 5: Ingest Pipelines:  Learn about Elasticsearch ingest pipelines.
- Elastic Geo Lab 6: ES|QL + Geo: Learn about using ES|QL with Geospatial data.

## Stay Connected
===

This workshop is just the beginning. Stay connected with us for more opportunities to learn about and get hands-on experience with Elastic via future workshops.

Click the **Next** button to proceed to Lab 1.