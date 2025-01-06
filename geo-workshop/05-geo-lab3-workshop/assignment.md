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
- id: zons3fekvhsd
  title: host
  type: terminal
  hostname: kubernetes-vm
difficulty: ""
timelimit: 600
enhanced_loading: null
---
In Lab 3, you’ll review some of the ES|QL's processing commands. We will cover more in later labs.

ES|QL Processing Command: where
===
<ins>Review</ins>: <code>where</code> uses conditions to filter rows from the input table that satisfy a given condition

<ins>Question 1</ins>: Write an ES|QL query that searches in apache-logs index for the following:
- source address
- http.request.method
- http.response.status_code greater or equal to 500
<details>
 <summary><ins>Answer</ins></summary>
 <code><pre>
 from apache-logs
 | keep source.address, http.request.method, http.response.status_code
 | where http.response.status_code >= 500
  </pre></code>
  </details>

ES|QL Processing Command: sort
===
<ins>Review</ins>: <code>sort</code> command orders the row of the output table based on the values of one or more field/columns.

<ins>Question 1</ins>: Using the previous ES|QL command, sort the response status codes in descending order:

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from apache-logs
| keep source.address, http.request.method, http.response.status_code
| where http.response.status_code >= 500
| sort http.response.status_code desc
</pre></code>
</details>

ES|QL Processing Command: where and like
===
<ins>Review</ins>: <code>like</code> is used to match strings using wildcards ? and *

<ins>Question 1</ins>: Write an ES|QL query that searches in apache-logs index for the following:
- What cityname contains the letter     s

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from apache-logs
| keep geoip.city_name
| where geoip.city_name like "*S*"
</pre></code>
</details>

ES|QL Source Commands: eval
===
<ins>Review</ins>: <code>eval</code> command allows you to calculate an expression and create a new field or column

<ins>Question 1</ins>: Write an ES|QL query to search the logstash-* index, using eval to convert bytes to kb. Keep the new bytes_to_kb and machine.os and limit the results to 100.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from logstash-*
| eval bytes_to_kb = (bytes/1024)
| keep bytes_to_kb, machine.os
| limit 100
</pre></code>
</details>

ES|QL Source Commands: rename
===
<ins>Review</ins>: <code>rename</code> is used to rename a field/column which can be helpful to standardize and bring clarity to names.

<ins>Question 1</ins>: Write an ES|QL query to search the employees index. Rename the field still_hired to employed and keep the fields first_name, last_name, and the newly renamed field employed

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from employees
| rename  still_hired AS employed
| keep first_name, last_name, employed
</pre></code>
</details>


Putting it all together
===

Using what we have learned so far, let's write an ES|QL query in phases.

<ins>Question 1</ins>: Write an ES|QL query searching the <code>kibana_sample_data_flights</code> limiting the results to 10

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| limit 10
</pre></code>
</details>

<ins>Question 2</ins>: Keep the Carrier, and FlightNum, AvgTicketPrice, and DistanceMiles columns.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| keep Carrier, FlightNum, AvgTicketPrice, DistanceMiles
| limit 10
</pre></code>
</details>

<ins>Question 3</ins>: Add a new column to your flights query containing the average cost per mile for each flight. As a hint, evaluate avg_cost_per_mile = ?

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| keep Carrier, FlightNum, AvgTicketPrice, DistanceMiles
| eval avg_cost_per_mile = AvgTicketPrice / DistanceMiles
| limit 10
</pre></code>
</details>

<ins>Question 4</ins>: Note that some of the avg cost per mile is infinity, this is because we are dividing by zero. Remove any DistancesMiles that has zero miles.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| keep Carrier, FlightNum, DistanceMiles, AvgTicketPrice
| where DistanceMiles > 0
| eval avg_cost_per_mile = (AvgTicketPrice / DistanceMiles)
| limit 10
</pre></code>
</details>

The order of operations in ES|QL does matter. Try changing the placement of <code> | limit 10 </code> and notice you will receive a different result.

<ins>Question 5</ins>: Now, sort the results of your flights query in descending order by cost per mile.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| keep Carrier, FlightNum, DistanceMiles, AvgTicketPrice
| where DistanceMiles > 0
| eval avg_cost_per_mile = (AvgTicketPrice / DistanceMiles)
| sort avg_cost_per_mile desc
| limit 10
</pre></code>
</details>

<ins>Question 6</ins>: Restrict your ES|QL query to only retrieve flights for Kibana Airlines carrier.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| keep Carrier, FlightNum, DistanceMiles, AvgTicketPrice
| where DistanceMiles > 0 and Carrier == "Kibana Airlines"
| eval avg_cost_per_mile = (AvgTicketPrice / DistanceMiles)
| sort avg_cost_per_mile desc
| limit 10
</pre></code>
</details>

<ins>Question 7</ins>: Add the timestamp column. It is shown in ISO8601 format and is a bit hard to read. Using the built in documentation within Kibana Discover, find the date function that will help you add an easy to read display_date column to your flights query. Use YYYY-MM-dd as a format.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
	| EVAL display_date = DATE_FORMAT("YYYY-MM-dd", timestamp)
	| keep timestamp, display_date, Carrier, FlightNum, AvgTicketPrice, DistanceMiles
	| where DistanceMiles > 0 and Carrier like "Kibana Airlines"
	| eval avg_cost_per_mile = AvgTicketPrice / DistanceMiles
	| sort avg_cost_per_mile desc
	| limit 10
</pre></code>
</details>

<ins>Question 8</ins>: Finally, add an identifier for each flight consisting of the concatenation of the Carrier, FlightNum, and the newly-created display_date columns. Sort the flights in descending order by id. Hint, you can remove the sort avg_cost_per_mile desc.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from kibana_sample_data_flights
| keep Carrier, FlightNum, timestamp, DistanceMiles, AvgTicketPrice
| where Carrier == "Kibana Airlines"
| eval avg_cost_per_mile = AvgTicketPrice / DistanceMiles
| eval display_date = date_format("YYYY-MM-dd", timestamp)
| eval flight_id = concat(Carrier, "-", FlightNum, "-", display_date)
| limit 10
| sort flight_id desc
</pre></code>
</details>

Congratulations, you have completed Lab 3. Click the **Next** button to proceed to Lab 4.