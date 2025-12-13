$(document).ready(function() {

  let c = tamil_matomo_conf;
  var _paq = window._paq = window._paq || [];

  _paq.push(['setTrackerUrl', c.matomo.url + '/' + 'matomo.php']);
  _paq.push(['setSiteId', c.matomo.siteid]);
  var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
  g.async=true; g.src=c.matomo.url+'/matomo.js'; s.parentNode.insertBefore(g,s);

  const trackPerPage = {
    main: (page) => {
      _paq.push(['trackPageView', page.title]);
    },
    advsearch: (page) => {
      _paq.push(['trackPageView', page.title]);
    },
    results: (page) => {
      let q = [];
      $('#bookbag_form input[type="hidden"]').each(function() {
        const name = $(this).attr('name');
        let value = $(this).val();
        if (name === 'idx' && value !== '') value += ':';
        else if (name === 'op') value = ' ' + value + ' ';
        q.push(value);
      });
      q = q.join('');
      _paq.push(['trackSiteSearch', q]);
      _paq.push(['trackPageView', `${page.title} : ${q}`]);
    },
    detail: (page) => {
      // Récupération du biblionumber
      let biblionumber;
      const { location } = window;
      const match = location.pathname.match(/\/bib\/(\d+)$/);
      if (match) {
        biblionumber = match[1];
      } else {
        const urlParams = new URLSearchParams(location.search);
        biblionumber = urlParams.get('biblionumber');
      }

      const title = $('h2.title').text();
      _paq.push(['trackEvent', 'Biblio', 'View', biblionumber]);
      _paq.push([
        'trackContentImpression',
        'Notice',              // contentName : catégorie générale
        biblionumber + ' : ' + title,        // contentPiece : identifiant unique
        location.href          // contentTarget : URL de la notice
      ]);
      _paq.push(['trackPageView', title]);
      _paq.push(['enableLinkTracking']);
    },
    page: (page) => {
      _paq.push(['trackPageView', page.title + ' : ' + $('.maincontent h1').text() ]);
      _paq.push(['enableLinkTracking']);

    },
  };

  const where = document.body.id;
  const { page } = c.opac;
  Object.keys(page).forEach((actionid) => {
    const thispage = page[actionid];
    if (where.startsWith(thispage.id)) {
      trackPerPage[actionid](thispage);
    }
  });
});


