$(document).ready(function() {
 
  let c = tamil_matomo_conf;
  var _paq = window._paq = window._paq || [];

  let u = "https://matomo.tamil.fr/";
  _paq.push(['setTrackerUrl', c.matomo.url + '/' + 'matomo.php']);
  _paq.push(['setSiteId', c.matomo.siteid]);
  var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
  g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);

  const where = document.body.id;
  const trackPerPage = {
    'advsearch': () => {
      _paq.push(['trackPageView', "Formulaire de recherche avancée"]);
    },
    'results': () => {
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
      _paq.push(['trackPageView', "Recherche : " + q]);
    },
    'opac-detail': () => {
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
      _paq.push(['trackEvent', 'Notice', 'Vue', biblionumber]);
      _paq.push([
        'trackContentImpression',
        'Notice',              // contentName : catégorie générale
        biblionumber + ' : ' + title,        // contentPiece : identifiant unique
        location.href          // contentTarget : URL de la notice
      ]);
      _paq.push(['trackPageView', title]);
      _paq.push(['enableLinkTracking']);
    },
  };
  trackPerPage[where]();
  
});


