---
slug: geo-lab6-workshop
id: ur6gqsxybxec
type: challenge
title: 'Elastic Geo Lab 6:  ES|QL + Geo [PLACEHOLDER]'
teaser: Learn about using ES|QL with Geospatial data.
notes:
- type: text
  contents: Please be patient as we set up the the lab 6 challenge.
tabs:
- id: livkbffwyyom
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
In Lab 6,  you will practice enriching the results of a query using an enrich policy.

From the lecture, ES|QL can use an enrich policy to add data from a separate index to the results of your queries. This is very similar to the enrich processor in Elasticsearch, except that ES|QL enrichment works at query time.
For the first portion of this lab, we will show the commands we used to build an enrich policy to be used later in our questions. We will then pull it all together and ingest data, create an enrich policy and query it.

Configuring Enrich Policy Example
===

The index we chose for the enrich policy is called geo-data. It contains the following mapping.

> [!NOTE]
> Do not run the following commands. This has already been done for you.

<details>
	<summary><int>geo-data mapping</int></summary>
<code><pre>
{
  "geo-data": {
    "mappings": {
      "_meta": {
        "created_by": "file-data-visualizer"
      },
      "properties": {
        "code_2": {
          "type": "keyword"
        },
        "code_3": {
          "type": "keyword"
        },
        "continent": {
          "type": "keyword"
        },
        "country": {
          "type": "keyword"
        },
        "country_code": {
          "type": "long"
        },
        "iso_3166_2": {
          "type": "keyword"
        },
        "region_code": {
          "type": "long"
        },
        "sub_region": {
          "type": "keyword"
        },
        "sub_region_code": {
          "type": "long"
        }
      }
    }
  }
}
</pre></code>
</details>

Here is a document sample from our geo-data
> [!NOTE]
> Do not run the following commands. This has already been done for you.

<details>
	<summary><int>Sample Document</int></summary>
<code><pre>
"_index": "geo-data",
        "_id": "oCIfZ4oBQHwMZSLzY0kZ",
        "_score": 1,
        "_source": {
          "continent": "Asia",
          "country": "Afghanistan",
          "country_code": 4,
          "sub_region_code": 34,
          "iso_3166_2": "ISO 3166-2:AF",
          "code_2": "AF",
          "code_3": "AFG",
          "sub_region": "Southern Asia",
          "region_code": 142
</pre></code>
</details>

To use the geo-data as an enrich source, we first create an enrich policy. The following enrich policy will add country, continent, and sub_region to any row that has a matching name. We executed the following commands in Kibana Devtools.

> [!NOTE]
> Do not run the following commands. This has already been done for you.

```
    PUT _enrich/policy/geo-data
    {
        "match": {
            "indices": "geo-data",
            "match_field": "code_2",
            "enrich_fields": [
                "country",
								"continent",
								"sub_region"
            ]
        }
    }
```
We then executed the policy so we can use it in a query.

> [!NOTE]
> Do not run the following commands. This has already been done for you.

```
POST _enrich/policy/geo-data/_execute
```

ES|QL Enrich Data
===

<ins>Question 1</ins>: Write an ES|QL query from the logstash-* index that finds the average bytes by geo source. Change bytes to kilobytes.

<details>
	<summary><int>Answer</int></summary>
<code><pre>
from logstash-*
| stats avg_bytes = avg(bytes) by geo.src
| eval avg_bytes_kb = avg_bytes/1024
| keep avg_bytes_kb, geo.src
| limit 10
</pre></code>
</details>

Notice that the output of this query under geo.src is a two digit country code.

<ins>Question 2</ins>: Using the previous command, use enrich to lookup the two digit code by using the enrich geo-data policy to find what country, continent does the two letter code represent. Round avg_bytes by 2 digits.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from logstash-*
| stats avg_bytes = avg(bytes) by geo.src
| eval avg_bytes_kb = round(avg_bytes/1024, 2)
| enrich geo-data on geo.src with country, continent
| keep avg_bytes_kb, geo.src, country, continent
| limit 10
</pre></code>
</details>

The next question uses a data set called projects with the fields of: name, owner, project_id, project_name, start_date, and tags.

<ins>Question 3</ins>: Write an ES|QL query to search on projects* dataset to lookup project_id with the enrich policy "servers-to-project" (without quotes) with name, ip_address, server_hostname, role, cost

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from projects*
| enrich servers-to-project on project_id with name, ip_address, server_hostname, role, cost
</pre></code>
</details>


ES|QL Enrich Data - Putting it all together
===

Let us do the entire process from data ingestion to policy enrichment creation to querying.

First we will need to ingest documents. We will do this from Kibana Dev Tools
1. From Kibana locate the menu button below the Elastic logo on the left side of the window.
2. Under "Management" section towards the very bottom, select "Dev Tools".

1. Begin by first creating the mapping. Copy the below command and paste it within Dev Tools. Don't forget to select the first line to run the command.
```
PUT products
    {
        "mappings": {
            "properties": {
            "product_name": {
                "type": "keyword"
            },
            "price": {
                "type": "double"
            }
            }
        }
    }
```
2.  Next ingest documents by running the following command in Dev Tools.
```
POST products/_bulk
    {"index": {"_id": "1"}}
    {"name": "apple", "price": 3.50}
    {"index": {"_id": "2"}}
    {"name": "orange", "price": 2.50}
    {"index": {"_id": "3"}}
    {"name": "pineapple", "price": 5.50}
    {"index": {"_id": "4"}}
    {"name": "watermelon", "price": 8.50}
```
You will use this product data set as an enrich source.

<ins>Question 1</ins>: Create an enrich policy that will add a product price to any row that has a matching name. Be sure to use Dev Tools to do this.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
PUT _enrich/policy/enrich-orders-with-price
    {
        "match": {
            "indices": "products",
            "match_field": "name",
            "enrich_fields": [
                "price"
            ]
        }
    }
</pre></code>
</details>

<ins>Question 2</ins>: Execute the policy so you can use it in a query. Be sure to use Dev Tools to do this.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
POST _enrich/policy/enrich-orders-with-price/_execute
</pre></code>
</details>

3.  Next we will create the mapping for a new data set called orders which we will use with our products enrich policy.
```
PUT orders
    {
        "mappings": {
            "properties": {
            "product_name": {
                "type": "keyword"
            },
            "customer_name": {
                "type": "keyword"
            },
            "quantity": {
                "type": "integer"
            }
            }
        }
    }
```

5. Ingest the following data set containing orders
```
POST orders/_bulk
    {"index": {}}
    {"product_name": "apple", "quantity": 5, "customer_name": "bob"}
    {"index": {}}
    {"product_name": "apple", "quantity": 5, "customer_name": "jane"}
    {"index": {}}
    {"product_name": "orange", "quantity": 1, "customer_name": "juan"}
    {"index": {}}
    {"product_name": "orange", "quantity":3, "customer_name": "juan"}
    {"index": {}}
    {"product_name": "apple", "quantity": 7, "customer_name": "jean-luc"}
    {"index": {}}
    {"product_name": "pineapple", "quantity": 1, "customer_name": "jane"}
    {"index": {}}
    {"product_name": "watermelon", "quantity": 2, "customer_name": "mario"}
    {"index": {}}
    {"product_name": "apple", "quantity": 2, "customer_name": "jane"}
    {"index": {}}
    {"product_name": "watermelon", "quantity": 5, "customer_name": "marc-andre"}
    {"index": {}}
    {"product_name": "pineapple", "quantity": 2, "customer_name": "marc-andre"}
    {"index": {}}
    {"product_name": "orange", "quantity": 8, "customer_name": "sidney"}
    {"index": {}}
    {"product_name": "apple", "quantity": 1, "customer_name": "sidney"}
```
6.  Now you are ready to enrich your data and answer the remaining question. Let's run the ES|QL from Kibana Discover. Remember to navigate to the menu button below the Elastic logo and select Discover. Ensure you have ES|QL selected in the Data Viewer and have set the time picker to last year.

<ins>Question 3</ins>: Write a query from the orders data set that finds the total sales for each of the products that have been ordered.

<details>
	<summary><ins>Answer</ins></summary>
<code><pre>
from orders |
keep product_name, quantity |
enrich enrich-orders-with-price on product_name |
eval order_total = quantity * price |
stats product_sales = sum(order_total), product_quantity = sum(quantity), price = median(price) by product_name
</pre></code>
</details>

Congratulations, you have completed Lab 6. Click the **Next** button to proceed to Lab 7.
