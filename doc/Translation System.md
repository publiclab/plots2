# Translation System 
Translation system is Public Labs is a project with the aim to foster diversity and make site more genial and accessible to new and existing users. In this project, the strings present in the infrastructure of the project are translated into various languages by volunatary contributors. 
Contributing to this project is a bit tedious and requires you to have a thorough knowledge about the various parts of code and their dependencies. I'll walk you through various parts and hopefully after this you can contribute to this project.

## YAML file
You can find language resource files stored as yaml files [here](https://github.com/publiclab/plots2/tree/main/config/locales). All the strings that are present in the translation project are stored in these files in the form of key value pairs. You can call these strings in view files using the key for each string.

## Translation function
You can find it [here](https://github.com/publiclab/plots2/blob/236381bc57d36361d1584059a94693e079744583/app/helpers/application_helper.rb#L157) . This is one of the most important part of the project. It basically returns translation of the string if it is present else returns a html tag with english translation of string and a globe icon besides it which tells translation team members that translation to this string is missing. 
The function is designed in  such a way that it presents two very similar experience to normal user and members of the translation team. 
### Experience for normal users
The translation function does not interfer with normal user experince it presents translated string if present or english translation if translation is not there. There are no globe icons rendered for normal users and UI breaks do not occur for normal users. This is done to prevent anonymous contributions and prevent site-wide UI breaks due to translation function.
### Experience for translation team members 
You can be a part of translation team by following this [wiki](https://publiclab.org/notes/liz/10-26-2016/how-to-join-public-lab-s-transifex-project) detailed wiki by @gauravano and @liz. The only difference in experience for members is the globe icons which can be seen at some places accross the site. More about it [here](https://publiclab.org/notes/ajitmujumdar25999/07-18-2021/globe-icon-for-translation-team-members). 
There are breaks in the UI sometimes for members, most of them have been fixed but as impacts nearly all pages and is constantly updated by first-time contributors some breaks can be missed out. Feel free to raise a issue if you find one.

## Calling translation function
The function works on the `i18n` gem [here](https://guides.rubyonrails.org/i18n.html) and [yaml file structure](https://github.com/publiclab/plots2/tree/main/config/locales). Each yaml file in mapped with corresponding translation resource on [Transifex project](https://www.transifex.com/publiclab/publiclaborg/dashboard/).This function from any `.html.erb` view files. Here is how the call looks
```
<%=translation('yaml key to string',option,html parameter)%>
```
There is one prerequisite to call translation function for a string, it should be present in the `en.yml` file else function won't correctly. In most of the cases, function call only requires the yaml keys. You can read more about yaml keys [here](https://yaml.org/spec/1.2/spec.html),I feel various calls that exist in the views files code are kind of self-explanatory. 
### Additional html parameter
This parameter helps deal with expection cases of translation function - sometimes globe icon cannot be correctly rendered in views in places like inside buttons and links. So to prevent UI break we add the `html parameter` as false in the translation function call. Here is a sample call
```
<%=translation('yaml key to string',{},false)%>
```
You can find calls like this in views that have translation function call in search bars and buttons.

Some improvements to this call can be reorganising the parameters to make it bit concise but it is tricky as lots of tests are written that follow the existing call structure, many function calls have this structure and also the gem has an inbuilt options parameter that can be passsed as array of options or as list of key value pairs , so for now, this call is simple to check and for now though a bit longer.

## Importing and exporting translations 
Moving on to the second part of the project. We use [Transifex](https://www.transifex.com/publiclab/publiclaborg/dashboard/) localisation platform to handle voluntary contributions and add them regualarly to the code-base. 
### Importing translation
We don't need to exclusively add new strings to the Transifex project.Adding it as a key-value pair in the `en.yml` file will do the trick. Transifex keeps track of the file and automatically adds new strigs at regular intervals. Managers and admins can also run a manual sync from `settings->integrations->Send to Github`.  option, more about it [here](https://publiclab.org/notes/ajitmujumdar25999/07-18-2021/importing-new-translations-from-transifex-project). Once imported you can find the string in the Transifex resource file. You can check by searching it in the translation search bar.
### Exporting translations 
 Transifex bot automatically raises a PR when a language resource is 100% reviewed. Managers and admins can also trigger a manual sync by `settings->integrations->Send to Github` option, we can specify a threshold percentage and any language files having reviewed percentage above the threshold will be added and a PR will be raised by the Transifex bot. Alternatively, we can also directly download a yaml file for the translation resource from the transifex site. More about it [here](https://publiclab.org/notes/ajitmujumdar25999/07-18-2021/importing-new-translations-from-transifex-project)

## Translation life-cycle
So now that you know all the aspects in this project, let's see how the entire project works. 
### Step 1: Adding a string
Add new strings as a key value pair in the `en.yml` file.
### Step 2: Importing string to Transifex project 
Transifex automatically fetches new strings from `en.yml` file. Managers and admins can also run manual sync to add strings to Project.
### Step 3: Translating string
Translation team members can add translations on the Transifex site. You can find a detailed wiki on how to do so [here](https://publiclab.org/wiki/translation?_=1629559376#Activities+for+people+who+want+to+translate+this+website)
### Step 4: Exporting translated strings
Once the string is reviewed,it can be added back to the Github repo. Transifex bot automatically raises a PR once language resource is 100% reviewed. Managers and admins can also trigger a manual sync.
### Step 5: Viewing Public Lab in other langauges
Once the translation are added to repository and changes are published, you can view the Public Lab site in different language by selecting the language of your choice from the footer of the dashboard page.

Hope you find this document helpful. Please feel free to improve it and reach out to the community incase you are still confused.


