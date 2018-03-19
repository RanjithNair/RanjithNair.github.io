---
layout: post
title: How to use Google sheets as a data source?
---

Google Sheets has been increasing becoming more popular especially in the field of finance and tracking data like home expenses. But the real beauty of it comes when you can use that as a data source to build beautiul UI's around it. So, lets get started as to how to go about this. 

1. Lets create a sample sheet with around 4 columns and 4 rows.

    <iframe src="https://docs.google.com/spreadsheets/d/e/2PACX-1vR9Zz8GPtYEc3mUC-7cpp8cjibITO0z0OkjT1TpxNlqHN1zLNhbyfg91fKcG4SRbP2R83dZ5oU4jvLZ/pubhtml?widget=true&amp;headers=false"></iframe>

2. One of the most important thing to be taken care of is to have the header fields defined so that we can easily access these attributes in our code. The way to assign header fields in Google sheets is to freeze the header row. The header field will be used as the key to access data for a particular column. 
 
    Go to `View --> Freeze --> 1 row`. You would see some kind of a line under that row indicating that the row is frozen. 
3. Click on "Share" and get the link. Make sure you select the option that `anyone with link can view`. Keep a note of the shareable link. 
4. Grab the Sheet ID from the link. 

5. You need to publish this file to web so as to be accessible on the internet. Goto `File --> Publish` to the web. Select the type as `webpage`.
6. The URL to fetch the JSON data from the sheet is in the below format. Paste the SheetID in the below URL. 

   `https://spreadsheets.google.com/feeds/list/<SHEET_ID>/od6/public/values?alt=json`

   In my case the sheet ID is `1wqdPvjqPoJNhBWrcj_v8PuBkTh7Fxw4fOUz7TLo1jxw`, so my API URL becomes :-
    `https://spreadsheets.google.com/feeds/list/1wqdPvjqPoJNhBWrcj_v8PuBkTh7Fxw4fOUz7TLo1jxw/od6/public/values?alt=json`

7. Awesome, now since we have the API URL to fetch the content of the sheet, lets quickly create a UI to display it. 

    The key point is here the way we access the data. The content of the sheet resides inside `feed.entry` and will be an array. Now to access individual attributes inside it, we will use the header fields whose rows we had frozen. So my React component to display the data becomes :-

    ```jsx
    const Stocks = ({ items }) => (
    <div className="table-responsive">
        <table className="table">
        <tbody>
            {items.map(item => (
            <tr>
                <td>{item["gsx$stock"]["$t"]}</td>
                <td>{item["gsx$price"]["$t"]}</td>
                <td>{item["gsx$quantity"]["$t"]}</td>
                <td>{item["gsx$date"]["$t"]}</td>
            </tr>
            ))}
        </tbody>
        </table>
    </div>
    );
    ```

    You can view the entire code here :-

    
    <iframe src="https://codesandbox.io/embed/mmkw3w2y99" style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;" sandbox="allow-modals allow-forms allow-popups allow-scripts allow-same-origin"></iframe>
