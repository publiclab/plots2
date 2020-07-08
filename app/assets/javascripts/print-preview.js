const PrettyPrintPage = {
  print: function () {

  // create a hidden iframe named PrettyPrintFrame
  const prettyPrintIframe = document.createElement('iframe');

  prettyPrintIframe.setAttribute('id', 'PrettyPrintFrame');
  prettyPrintIframe.setAttribute('name', 'PrettyPrintFrame');
  prettyPrintIframe.setAttribute('style', 'display: none;');

    // add newly created iframe to the current DOM
    document.body.appendChild(prettyPrintIframe);

  // add generated header content
  //prettyPrintIframe.contentWindow.document.head.innerHTML = this.generateHeaderHtml();

    // add generated body content
  prettyPrintIframe.contentWindow.document.body.innerHTML = this.generatePrintLayout();

    try {
        // reference to iframe window
        const contentWindow = prettyPrintIframe.contentWindow;

        // execute iframe print command
        const result = contentWindow.document.execCommand('print', false, null);

        // iframe print listener
        const printListener = contentWindow.matchMedia('print');
        printListener.addListener(function(pl) {
          if (!pl.matches) {
            // remove the hidden iframe from the DOM
            // prettyPrintIframe.remove();
          }
        });

        // if execCommand is unsupported
        if(!result) { contentWindow.print(); }

      } catch (e) {
        // print fallback
        window.frames['PrettyPrintFrame'].focus();
        window.frames['PrettyPrintFrame'].print();
      }
  },
  generatePrintLayout: function () {
    // this function houses your default header/footer details and the switch to identify your pages by

    let html = '<html>';
    html += this.generateGlobalCss();

    // add logo
    //html += '<h3 style="margin-bottom: 16px;">PublicLab Pretty Printed Page Header</h3>';
    url = window.location.pathname
    console.log(url);
    if(url.includes('/wiki/')){
      html += this.wikiResults();
    }
    else{
    html += this.noteResults();
  }

    // global footer elements
    html += this.generateFooterHtml();
    console.log(html);

    return html;
  },
  generateHeaderHtml: function () {
    return headerHtml;
  },
  generateGlobalCss: function () {
    let css = '<style>';
    // global css
    // for info styling
    css += '.info-author{color:rgb(49,49,49); font-size: 12pt;} .info-date{display:inline-block;color:rgb(102,102,102); font-size: 10pt; text-transform: uppercase} .info-revision{background-color:rgb(241,243,245); color:rgb(60,60,59); padding:5px; display:inline-block;float:right}';
    // for page break strategy
    css += 'ul,ol{break-inside: avoid;break-before: avoid-page;}';
    css += 'ul, table, img, svg{break-inside: avoid;} img{display: block;page-break-before: auto;page-break-after: auto;page-break-inside: avoid;break-before: avoid-page; padding:5px; border: 0.2em solid;margin-left: auto;margin-right: auto;width: 50%;} #main-image-print{width:100%;border:none;} #profile-photo{float:left;border-radius:50%;border-style:none;margin-left: none;display:block;}';
    css += 'h1{break-before: always;} h2,h3,h4,h5,h6{break-after: avoid-page;break-inside: avoid;}';
    // for tables
    css += 'table {width: 100%; font: 17px Calibri;}';
    css += "table, th, td {border: solid 1px #DDD; border-collapse: collapse; padding: 2px 3px; text-align: center;}";
    //for blockquote
    css += 'blockquote {position: relative;padding-left: 1em;border-left: 0.2em solid ;font-weight: 100;break-inside: split;}'
    css +='blockquote:before, blockquote:after {content: "\\201C";} blockquote:after {content: "\\201D";}'
    //for font styling and size
    css += 'html {font-family: "arial";font-size: 12pt;line-height: 1.2;}';
    css += 'h1{font-size: 180%;} h2{font-size: 160%;} h3{font-size: 140%;} h4{font-size: 120%;}';
    //for link handling
    css += 'a:link,a:visited,a{background: transparent;color: #000;font-weight: bold;text-decoration: underline;text-align: left;}';
    css += 'a{break-inside: avoid;}';
    css += 'a[href^=http]::after{content: "<" attr(href) ">";}';
    // for beautifying print layout
    css += '.title{ text-align:center;}'
    // for showing the hidden coauthor profile images on notes/wiki#show
    css += '.coauthor-photo{display:unset;}';
    css += '.wiki-authors,.wiki-revisions,.wiki-date{display:unset;} .wi-author{font-weight:bold;text-decoration:underline;}';
    css += '</style>';
    return css;
  },
  generateFooterHtml: function () {
    let footerHtml = '<hr style="margin: 24px 0 8px;">';

    footerHtml += 'Global footer text - PublicLab ' + ( new Date().getFullYear() );
    footerHtml += '</body></html>';

    return footerHtml;
  },
  noteResults: function() {
    let html = '';
    let resultTitle = document.getElementById('note-title');
    let resultAuthor = document.querySelector('#note-author').innerText;
    let resultCoauthors = null;
    let resultCoauthorsPhoto = null;
    if(document.querySelector('.note-coauthors'))
    {resultCoauthors = document.querySelectorAll('.note-coauthors');}
    if(document.querySelector('.coauthor-photo'))
    {resultCoauthorsPhoto = document.querySelectorAll('.coauthor-photo');}
    let resultDate = document.querySelector('#note-date').innerText;
    let resultTime = document.querySelector('#note-time').innerText;
    let resultItems = document.getElementById('content');
    let profile_image = document.getElementById('profile-photo').outerHTML;
    let resultInfo = document.getElementById('info').innerHTML;
    html += '<div>';
    html += '<p class="info-date"><i><b>' + resultDate + " / " + resultInfo.slice(resultInfo.lastIndexOf("|")+2) + '</b></i></p>';
    html += '<h1>' + resultTitle.innerText + '</h1>';
    html += '<p class="info-author">' + profile_image + "  " + resultAuthor +  '</p>';
    if(resultCoauthors!==null){resultCoauthors.forEach(function(co,i) {
      html += '<p class="info-author">' + resultCoauthorsPhoto[i].outerHTML + "  " + co.innerText +  '</p>';});}
    if(document.querySelector('#main-image-print'))
    {html += document.querySelector('#main-image-print').outerHTML;}
    html += resultItems.outerHTML;
    html += '</div>'
    return html;
  },
  wikiResults: function() {
    let html = '';
    let resultTitle = document.getElementById('wiki-title');
    let resultItems = document.getElementById('content');
    let resultInfo = document.getElementById('info').innerHTML;
    let resultDate = document.querySelector('.wiki-date').innerText;
    let resultNoRevisions = document.querySelector('.wiki-revisions').innerText;
    console.log(resultDate);
    console.log(resultNoRevisions);
    let resultAuthorsPhoto = null;
    if(document.querySelector('.author-photo'))
    {resultAuthorsPhoto = document.querySelectorAll('.author-photo');}
    let resultAuthors = document.querySelectorAll('.wiki-authors');
    html += '<div>';
    html += '<div class="row"><p class="info-date"><i><b>' + resultDate + " / " + resultInfo.slice(resultInfo.lastIndexOf("|")+2) + '</b></i></p>';
    html += '<p class="info-revision">' +resultNoRevisions + ' revisions </p></div>';
    html += '<h1 class="title">' + resultTitle.innerText + '</h1>';
    html += '<p>By: '
    resultAuthors.forEach(function(author,i){
      if (i < resultAuthors.length - 2) {html +=  "<i class='wi-author'>" + author.innerText + "</i>, ";}
      else if (i === resultAuthors.length - 2) {html +=  "<i class='wi-author'>" + author.innerText + "</i> ";}
      else{html +=  "and <i class='wi-author'>" + author.innerText + "</i>";}});
    html += '</p>';
    if(document.querySelector('#main-image-print')){html += document.querySelector('#main-image-print').outerHTML;}
    html += resultItems.outerHTML;
    html += '</div>'
    return html;}
};

// override Ctrl/Cmd + P
document.addEventListener("keydown", function (event) {
  if((event.ctrlKey || event.metaKey) && event.key === "p") {
        PrettyPrintPage.print();
        event.preventDefault();
        return false;
    }
} , false);
