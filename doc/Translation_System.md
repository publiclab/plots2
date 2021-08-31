# Translation System

The Translation system of the Public Lab codebase is a project with the aim to foster diversity and make site more genial and accessible to new and existing users. In this project, the strings or texts present in the infrastructure (i.e. codebase) of the project are translated into various languages by volunatary contributors. 

Contributing to this project can seem a bit tedious and requires you to have a thorough knowledge about the various parts of code and their dependencies. I'll walk you through various parts and hopefully after this you can contribute to this project.

## YAML file

You can find language resource files stored as YAML files [here](https://github.com/publiclab/plots2/tree/main/config/locales). All the strings that are present in the translation project are stored in these files in the form of key value pairs. You can call these strings in view files using the key for each string. Each language has its own YAML file, named after the language's standard code - i.e. English is `en.yml` and German is `de.yml`

## Translation helper

There is a custom Ruby helper function which we've created to simplify using translation strings in the codebase. You can find it [here](https://github.com/publiclab/plots2/blob/236381bc57d36361d1584059a94693e079744583/app/helpers/application_helper.rb#L157) . This is one of the most important part of the project. It basically returns translation of the string if it is present, or else returns a html tag with the English translation of the string and a globe icon beside it which tells the [translation team members](https://publiclab.org/translation) that translation to this string is missing. Note that this globe icon prompt is a unique feature of our helper function and not a default behavior of the Ruby `i18n` gem. 

The function is designed in  such a way that it presents two very similar experience to normal user and members of the translation team. 

### JavaScript translation helper

There is a corresponding JavaScript version of this function, however it is not as well documented at this time. It's documented at: http://i18njs.com/ and you can see it in action on this line of code: https://github.com/publiclab/plots2/blob/e646cfd248e46fe9cf11a2eb7860bbf29f949b7d/app/assets/javascripts/dashboard.js#L139

### Experience for normal users

The translation function does not interfere with normal user experince it presents translated string if present or English translation if translation is not there. There are no globe icons rendered for normal users and UI breaks do not occur for normal users. This is done to prevent anonymous contributions and prevent site-wide UI breaks due to translation function.

### Experience for translation team members 

You can be a part of translation team by following this [wiki](https://publiclab.org/notes/liz/10-26-2016/how-to-join-public-lab-s-transifex-project) detailed wiki by @gauravano and @liz. The only difference in experience for members is the globe icons which can be seen at some places accross the site. More about it [here](https://publiclab.org/notes/ajitmujumdar25999/07-18-2021/globe-icon-for-translation-team-members). 
There are breaks in the UI sometimes (especially if translations are used within complex HTML UI elements like menus, buttons, or forms), but most of them have been fixed but as impacts nearly all pages and is constantly updated by first-time contributors some breaks can be missed out. Feel free to raise a issue if you find one.

## Calling translation function

The function works on the `i18n` gem [here](https://guides.rubyonrails.org/i18n.html) and [yaml file structure](https://github.com/publiclab/plots2/tree/main/config/locales). Each yaml file in mapped with corresponding translation resource on [Transifex project](https://www.transifex.com/publiclab/publiclaborg/dashboard/).This function from any `.html.erb` view files. 

Here is how the call looks

```ruby
<%= translation('yaml key to string',option,html parameter) %>
```

See an [example here](https://github.com/publiclab/plots2/blob/e646cfd248e46fe9cf11a2eb7860bbf29f949b7d/app/views/dashboard/_header.html.erb#L6)

There is one prerequisite to call translation function for a string, it should be present in the [`en.yml` file](https://github.com/publiclab/plots2/tree/main/config/locales/en.yml) else function won't correctly. In most of the cases, function call only requires the YAML keys. You can read more about YAML keys [here](https://yaml.org/spec/1.2/spec.html), I feel various calls that exist in the views files code are kind of self-explanatory. 

### Additional html parameter

This parameter helps deal with expection cases of translation function - sometimes globe icon cannot be correctly rendered in views in places like inside buttons and links. So to prevent UI break we add the `html parameter` as false in the translation function call. Here is a sample call

```ruby
<%= translation('dashboard._header.community_research', {}, false) %>
```

You can find calls like this in views that have translation function call in search bars and buttons.

Some improvements to this call can be reorganising the parameters to make it bit concise but it is tricky as lots of tests are written that follow the existing call structure, many function calls have this structure and also the gem has an inbuilt options parameter that can be passsed as array of options or as list of key value pairs , so for now, this call is simple to check and for now though a bit longer.

![Untitled Diagram](https://user-images.githubusercontent.com/38528640/131227801-aa46fe85-a2a0-4385-833f-36f6d433d3fe.png)


## Importing and exporting translations 

Moving on to the second part of the project. We use [Transifex](https://www.transifex.com/publiclab/publiclaborg/dashboard/) localisation platform to handle voluntary contributions and add them regualarly to the code-base. 

### Importing translation

We don't need to exclusively add new strings to the Transifex project. Adding it as a key-value pair in the `en.yml` file will do the trick. Transifex keeps track of the file and automatically imports new strings from GitHub at regular intervals. Managers and admins can also run a manual sync from the `settings->integrations->Send to Github` option, more about it [here](https://publiclab.org/notes/ajitmujumdar25999/07-18-2021/importing-new-translations-from-transifex-project). Once imported you can find the string in the Transifex resource file. You can check by searching it in the translation search bar.

Here is where managers can trigger a pull request
![Screenshot from 2021-07-18 14-28-34](https://user-images.githubusercontent.com/38528640/131228051-a602d83f-1cca-4d30-a064-bf43516cc562.png)

### Exporting translations 

 Transifex bot automatically raises a PR when a language resource is 100% reviewed. Managers and admins can also trigger a manual sync by `settings->integrations->Send to Github` option, we can specify a threshold percentage and any language files having reviewed percentage above the threshold will be added and a PR will be raised by the Transifex bot. Alternatively, we can also directly download a yaml file for the translation resource from the transifex site. More about it [here](https://publiclab.org/notes/ajitmujumdar25999/07-18-2021/importing-new-translations-from-transifex-project)
Here is a [sample pull request](https://github.com/publiclab/plots2/pull/10079)

## Translation life-cycle

So now that you know all the aspects in this project, let's see how the entire project works. 

### Step 1: Adding a string

Add new strings as a key value pair in the `en.yml` file.

### Step 2: Importing string to Transifex project 

Transifex automatically fetches new strings from `en.yml` file. Managers and admins can also run manual sync to add strings to Project.

### Step 3: Translating string

Translation team members can add translations on the Transifex site. You can find a detailed wiki on how to do so [here](https://publiclab.org/wiki/translation#Activities+for+people+who+want+to+translate+this+website)

### Step 4: Exporting translated strings

Once the string is reviewed,it can be added back to the Github repo. The Transifex bot automatically raises a PR once language resource is 100% reviewed. Managers and admins can also trigger a manual sync, which you can do by [opening an issue at the plots2 repository](https://github.com/publiclab/plots2/issues/new), specifying which language you're interested in.

### Step 5: Viewing Public Lab in other langauges

Once the translation are added to repository and changes are published, you can view the Public Lab site in different language by selecting the language of your choice from the footer of the dashboard page.

Hope you find this document helpful. Please feel free to improve it and reach out to the community in case you are still confused.


