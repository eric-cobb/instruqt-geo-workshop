---
slug: geo-lab4-workshop
id: fknldrj1tup9
type: challenge
title: 'Elastic Geo Lab 4: Machine Learning Anomalies [PLACEHOLDER]'
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
In Lab 4, you will practice extracting data from structuring strings using dissect and grok.

ES|QL Processing Command: dissect
===
<ins>Review</ins>: <code>dissect</code>  matches the string against a delimiter-based pattern, and extracts the specified keys as fields/columns.

We are going to use <code>row</code> to create a result row so we can easily practice apply commands and functions to it. Copy the following command (sample message from a data log) into ES|QL query box.

```
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
```
The message string contains quite a few data elements we would want to extract into their own columns, IP, ISO 8601, REST method, URI, response code, the number of bytes, and the user-agent. From the lecture, dissect extracts data out of a string using a delimiter-based pattern. The following commands extract the first item in the string, which is an IP address.

```
 row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| dissect message "%{ip} "
| keep ip
```
> [!NOTE]
> Note that the substring captured by the %{ip} key is delimited by the first space found in the string.

<ins>Question 1</ins>: Extract the second item, which is an ISO 8601 timestamp.

<details>
	<summary><int>Answer</int></summary>
<code><pre>
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| dissect message "%{ip} - - [%{@timestamp}]"
| keep ip, @timestamp
</pre></code>
</details>

<ins>Question 2</ins>: Extract the third and fourth items, which is a REST method and the URI.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| dissect message "%{ip} - - [%{@timestamp}] \"%{method} %{uri} HTTP/1.1\""
| keep ip, @timestamp, method, uri
</pre></code>
</details>

<ins>Question 3</ins>: Finally, extract the the response code,  the number of bytes, and the user-agent.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| dissect message "%{ip} - - [%{@timestamp}] \"GET %{url} HTTP/1.1\" %{response} %{bytes} \"-\" \"%{agent}\""
| keep ip, @timestamp, url, response, bytes, agent
</pre></code>
</details>


ES|QL Processing Command: grok
===
<ins>Review</ins>: <code>grok</code> matches the string against patterns, based on regular expressions, and extracts the specified patterns as columns.

The grok processor, addresses some of the shortcomings in <code>dissect</code> like  sensitivity to spaces and tabs and invalid formats. From the lecture, grok comes out of the box with a good number of patterns for many use cases.
The following commands extract the IP address from the message.

```
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| grok message "%{IP:ip}"
| keep ip
```
Now lets provide an invalid IP address <code>981.157.71.85</code>
```
row message = "981.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| grok message "%{IP:ip}"
| keep ip
```
<code>grok</code> rejects the invalid IP address since it does no match the regular expression that defines the IP pattern and null is returned.

<ins>Question 1</ins>: Using the same row message above, capture the the timestamp

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| grok message "%{IP:ip} - -%{SPACE}\\[%{TIMESTAMP_ISO8601:@timestamp}\\]"
| keep ip, @timestamp
</pre></code>
</details>

<ins>Question 2</ins>: Capture the remaining items. HINT: You can use the TIMESTAMP_ISO8601, WORD, URIPATH, NUMBER, and DATA grok patterns.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
row message = "81.157.71.85 - - [2018-08-29T12:33:48.962Z] \"GET /elasticsearch/elasticsearch-6.3.2.tar.gz HTTP/1.1\" 200 8222 \"-\" \"Mozilla/5.0 (X11; Linux x86_64; rv:6.0a1) Gecko/20110421 Firefox/6.0a1\""
| grok message "%{IP:ip} - -%{SPACE}\\[%{TIMESTAMP_ISO8601:@timestamp}\\] \"%{WORD:method} %{URIPATH:uri} HTTP/1.1\" %{NUMBER:response} %{NUMBER:bytes:int} \"-\" \"%{DATA:agent}\""
| keep ip, @timestamp, method, uri, response, bytes, agent
</pre></code>
</details>

We will use grok later in this workshop.

Congratulations, you have completed Lab 4. Click the **Next** button to proceed to Lab 5.
