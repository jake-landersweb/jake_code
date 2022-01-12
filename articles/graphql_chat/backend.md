
[AWS Amplify](https://aws.amazon.com/amplify/) is a powerful tool provided by Amazon Web Services that allows you to quickly build fullstack applications. It provides an efficient way to incorporate a backend hosted on AWS to your frontend UI, allowing your backend to scale infinitely in the cloud.

In this multipart series, we will be building an AWS AppSync GraphQL api to serve a number of frontends including [Flutter](https://flutter.dev) for mobile devices, [SwiftUI](https://developer.apple.com/xcode/swiftui/) for iPads and Macs, and the Web using [React](https://reactjs.org) and [tailwindcss](https://tailwindcss.com). 

This article will focus on the AWS AppSync set up process, and how to perform graphql queries.

## Initial Setup

If you have not set up an AWS account, you can do so [here](https://portal.aws.amazon.com/billing/signup?refid=ps_a131l0000085dvcqae&trkcampaign=acq_paid_search_brand&redirect_url=https%3A%2F%2Faws.amazon.com%2Fregistration-confirmation#/start). The AWS console gives you access to hundreds of Amazon services from AI to managed database systems.

Once you have an account, log into the console and search for <code>AWS AppSync</code>.

<img src="https://jakelanders.com/media/images/chat_app_sync_search.png" alt="AWS AppSync Service Search on Console" height="300px">

Here you will see a list of your apis. Click on the orange <code>Create API</code> button, choose <code>Build from scratch</code> and click <code>Start</code>.

<img src="https://jakelanders.com/media/images/chat_app_sync_create.png" alt="AWS AppSync Create API" height="300px">

Give it a name, like "AWS Chat" and click <code>Create</code>.

## Define Types

Now, you are in your managed API window. On the left, select <code>Schema</code>. On this screen, click <code>Create Resource</code>. Here, you will define a graphql schema type, create a [DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/Introduction.html) table to store your data, and have schema code auto generated for you based on the data you provide. 

First, we are going to define our Room object. This will store information about a room like it's title, along with some ID information to help manage messages. This tutorial is meant to give you an easy way to implement chat into your own existing application, so the Room object's <code>id</code> field will be up to you to create. In this example, we will use the id "1".

for the schema, we will use the following:

```graphql
type Room {
	id: String!
	roomId: String!
	title: String!
	created: String!
}
```

Below, we will create a table with the name <code>RoomTable</code>, set the Primary Key to be <code>id</code>, and set the Sort Key to be <code>roomId</code>.

<img src="https://jakelanders.com/media/images/chat_schema_create.png" alt="AWS AppSync Schema Create" height="700px">

Scroll to the bottom and select <code>Create</code>. This will create the needed table and define boilerplate graphql schema code.

Next, we will need to do the same process for the <code>Message</code> type. The schema is as follows:

```graphql
type Message {
    roomId: String!
    messageId: String!
    message: String!
    name: String!
    created: String!
}
```

And the table configuration will be;
- Primary Key = roomId
- Sort Key = messageId

Then click <code>Create</code>. This will again create the needed table and boilerplate code.

## Resolver Config

Next there is some cleanup of the resolvers that were auto generated. When the code was generated, the <code>mutation</code> functions <code>listRooms</code> and <code>listMessages</code> use scan operations. This will be fine for a while, but as your application scales you will see slower speeds.

We need to adjust the resolvers to use the <code>Query</code> command. On the right, select <code>Schema</code>. Then, on the right side of the page in Resolvers, scroll down to <code>Query</code> then select the resolver for <code>listRooms</code>.

You can see here that the <code>operation</code> field uses "Scan". We can change this easily to the "Query" type with the following template:

```json
{
  "version": "2017-02-28",
  "operation": "Query",
  "query" : {
    "expression": "id = :id",
      "expressionValues" : {
        ":id" : { "S" : "$context.arguments.id" },
      }
  },
  "limit": $util.defaultIfNull($ctx.args.limit, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
  "scanIndexForward": true
}
```

Click <code>Save Resolver</code> then navigate back to Schema. Repeat this same process for </code>listMessages</code> using the following template:

```json
{
  "version": "2017-02-28",
  "operation": "Query",
  "query" : {
    "expression": "roomId = :roomId",
      "expressionValues" : {
        ":roomId" : { "S" : "$context.arguments.roomId" },
      }
  },
  "limit": $util.defaultIfNull($ctx.args.limit, 20),
  "nextToken": $util.toJson($util.defaultIfNullOrEmpty($ctx.args.nextToken, null)),
  "scanIndexForward": false
}
```

We set the <code>scanIndexForward</code> flag as <code>false</code> to retrieve the messages in reverse order, which in our case will be most recently posted first.

Now, we need to edit the <code>createRoom</code> and <code>createMessage</code> resolver. This will allow us to define the <code>sortKey</code> that gets generated on our objects and the <code>created</code> field.

The mapping template for <code>createRoom</code> is as follows:

```json
{
  "version": "2017-02-28",
  "operation": "PutItem",
  
  #set( $body = {} )

  #set( $roomId = "${util.time.nowEpochMilliSeconds()}${util.autoId()}")
  $!{body.put("id", $ctx.args.input.id)}
  $!{body.put("roomId", $roomId)}
  $!{body.put("title", $ctx.args.input.title)}
  $!{body.put("created", $util.time.nowISO8601())}
  
  "key": {
    "id": $util.dynamodb.toDynamoDBJson($ctx.args.input.id),
    "roomId": $util.dynamodb.toDynamoDBJson($body.roomId),
  },
  "attributeValues": $util.dynamodb.toMapValuesJson($body),
  "condition": {
    "expression": "attribute_not_exists(#id) AND attribute_not_exists(#roomId)",
    "expressionNames": {
      "#id": "id",
      "#roomId": "roomId",
    },
  },
}
```

We set the <code>roomId</code> field to be a combination of epoch time and a hex ID to ensure that all entires will be stored in chronological order. This is less important for rooms, but critical for messages. Click <code>Save Resolver</code>.

The same needs to be done for <code>Message</code>:

```json
{
  "version": "2017-02-28",
  "operation": "PutItem",
  
  #set( $body = {} )

  #set( $messageId = "${util.time.nowEpochMilliSeconds()}${util.autoId()}")
  $!{body.put("roomId", $ctx.args.input.roomId)}
  $!{body.put("messageId", $messageId)}
  $!{body.put("message", $ctx.args.input.message)}
  $!{body.put("name", $ctx.args.input.name)}
  $!{body.put("created", $util.time.nowISO8601())}
  
  "key": {
    "roomId": $util.dynamodb.toDynamoDBJson($ctx.args.input.roomId),
    "messageId": $util.dynamodb.toDynamoDBJson($body.messageId),
  },
  "attributeValues": $util.dynamodb.toMapValuesJson($body),
  "condition": {
    "expression": "attribute_not_exists(#roomId) AND attribute_not_exists(#messageId)",
    "expressionNames": {
      "#roomId": "roomId",
      "#messageId": "messageId",
    },
  },
}
```

Click <code>Save Resolver</code>, and head back to <code>Schema</code>.

We now need to slightly edit the <code>CreateRoomInput</code> and <code>CreateMessageInput</code> to match what fields we use in our resolvers. For <code>CreateRoomInput</code>, we will remove the <code>roomId</code> and <code>created</code> fields, as these are created for us in the custom resolver. For <code>CreateMessageInput</code>, we will remove the <code>messageId</code> and <code>created</code> fields, for the same reason above.

The final bit of setup is editing the <code>Subscription</code> schema. AWS autogenerated us subscribers for every function create, but we are only going to utilize <code>onCreateMessage</code>. We remove all the others, and set the arguments to only contain <code>roomId</code>. This looks like the following:

```graphql
type Subscription {
	onCreateMessage(roomId: String): Message
		@aws_subscribe(mutations: ["createMessage"])
}
```

Click <code>Save Schema</code> in the top right corner.

## Running Queries

Now that all of our configuration is done, we can head to the <code>Queries</code> section on the side bar and run some sample queries.

We will select <code>Mutation</code> from the dropdown on the left and then select the <code>createRoom</code> dropdown arrow. From here, we will check all of the available boxes which will autofill the query on the middle screen. Fill in the <code>input</code> and <code>title</code> fields then run the query with the orange play button.

<img src="https://jakelanders.com/media/images/chat_query_example.png" alt="GraphQL Query Example" height="300px">

> Note: My example here uses "sortKey" instead of "roomId", replace it with the value you are using.

With a room created, we can create a few sample messages:

```graphql
mutation CreateMessage {
  createMessage(input: {message: "My first message", name: "jake", roomId: "1"}) {
    created
    message
    messageId
    name
    roomId
  }
}
```

Lastly, we can list all of our messages with the following command:

```graphql
query ListMessages {
  listMessages(roomId: "1", limit: 10, nextToken: "") {
    items {
      created
      message
      messageId
      name
      roomId
    }
    nextToken
  }
}
```

And that is it! The backend for our chat database is ready to be utilized by the front end framwork of your choice. If you want an integrated tutorial using the exact backend created above, consider checking out my tutorials doing exactly that.

- [Flutter - coming soon]()
- [SwiftUI - coming soon]()
- [React with tailwindcss - coming soon]()
