---
layout: post
title: How to setup your blog with Jekyll & Github pages
---

As part of new year resolution, i finally decided to start my own blog to share my learning on the programming end. I came across multiple reddit posts on the eve of new year sharing some [resolutions for programmers](http://matt.might.net/articles/programmers-resolutions/). I have always felt that instead of relying on the number of followers for your blog, it's kind of personal gain for me to keep a journal of my own learnings. 

### Initial Analysis - Comparison of Alternatives

So, to start off i started looking out in Google and Reddit to see developers usually chose which platform - CMS like Wordpress, Medium etc or Jekyll with Github pages. Finally, i went ahead with Jekyll and deploying on Github pages. I was particularly inclined towards this option due to the below reasons :-

* A one-stop site wherein you have your hosted projects and blogs. 
* Developing knowledge on Markdown. Jekyll uses Markdowns to build your content which in turn is passed on to your templates and then finally rendered.
* No issues about hosting and all - Once you commit your changes to Git, the site would be up in seconds. 
* Abundant Theme support.

### Setting up

There were multiple ways to setup such a blog and i found couple of tools which makes it easier to setup this :-

* [Jekyll-now](https://github.com/barryclark/jekyll-now)
* [Poole](http://getpoole.com/)

Since, i was more interested in a minimalist-setup, i went ahead with a theme( [Lanyon](https://github.com/poole/lanyon) ) which was built on Poole. Below are the steps, i did to get it working :-

* Clone the [Git repository](https://github.com/poole/lanyon) to my Github repo.
* Once that's done, change the repo name to "<your-github-profile-name>.github.io". 
* Give it a few seconds, and your blog site would be published in the URL - https://www.<your-github-profile-name>.github.io .

### Customizing Blog

Now, this part was simple and then i wanted to customize this site as per my needs. I started looking for Markdown editors which would easily allow me to edit and build content. I came across [Prose](http://prose.io/) which links to your Github repo and allows yout to directly edit and commit changes. 

But, i wanted to try out on my local before even publishing the changes to my Github repo. So, i started working on getting to run this site on my local system. I had to follow the below steps :-

* Installing Ruby: Since i had a Windows laptop, i had to follow some extra steps to get this working. Luckily, there was already a site to help out with this challenge. This [site](http://jekyll-windows.juthilo.com/1-ruby-and-devkit/) explained in detail how to install Ruby & Ruby Dev Kit for Windows.   
* Installing Jekyll: `gem install jekyll`
* Clone your Github repo to local: `git clone <github-repo> <local-directory>`
* Start up the server by `jekyll serve`.

###Issue Time
I faced some issues after trying to bring up the server :-

* First, it gave me the below error:-

	`Deprecation: You appear to have pagination turned on, but you haven't included the 'jekyll-paginate' gem. Ensure you have 'gems: [jekyll-paginate]' in your configuration file.`


	It seemed like, Poole was not quite completely built for Jekyll 3. To resolve this, i installed the paginate package by `gem install jekyll-paginate`.

* After that error was gone, i came across another one :-

	`Since v3.0, permalinks for pages in subfolders must be relative to the site source directory, not the parent directory. Check http://jekyllrb.com/docs/upgrading/ for more info.`

	In order to resolve this, i commented out the below line in _config.yaml.
	`#relative_permalinks: true`

* When i tried to click on the post, it was opening with an incorrect URL. On further analyzing, i saw the below code in index.html which was resulting in the issue :-

	Since my baseurl was empty, it was creating double slash for the URL of the post. In order to fix it, i just removed the slash between baseurl and the actual post URL.


~~~html
<h1 class="post-title">
	  {% raw %}	
      <a href="{{ site.baseurl }}/{{ post.url }}">
        {{ post.title }}
      </a>
      {% endraw %}
</h1>
~~~

In order to show the above code, i was facing an issue wherein i had to escape double curly braces. And for doing that, we need to put the code block within *raw && endraw*.

	
And finally, i was able to bring up the site in my local machine. Now, the only question I had was how to enable live-reloading if the content changes. Jekyll allows that by bringing up the server by : `jekyll server --watch`

Later, i tried to add posts with the same file name format and found that if you create a MD file with future date, Jekyll prevents that from showing :)

### Integrating Site Analytics and Comments

* **Site Analytics**: I went ahead and integrated Google Site Analytics to my blog site. For this, i created a profile and got the ID. After that i created a html file wherein i pasted the JS code supplied by Google within _includes folder. Finally i added that file within my default.html.

* **Comments**: For comments, i chosed Disquss comments. Created a profile in Disquss and got the unique name identifier. Created a HTML file within _includes folder. Make sure to edit the Disquss shortname. And i finally added that file within default.html.

~~~html
<div class="container content">
        {{ content }}
        {% include comments.html %}
</div>
~~~ 

I finally started my editing in my local setup and then published my changes to Git. This was far better than doing multiple commits to Git repo and then checking.

