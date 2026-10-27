# Plugin Koha ⇄ Matomo

**Koha ⇄ Matomo** est un plugin qui facilite l'intégration d'un OPAC Koha au
système de mesure de la fréquentation d'un site web [Matomo](https://matomo.org).
Il insère le code de suivi Matomo dans les pages de l'OPAC et enrichit les
statistiques avec des informations propres à Koha : recherches effectuées,
notices consultées, pages éditoriales.

Aucune modification de la préférence système `OPACUserJS` n'est nécessaire :
le plugin injecte lui-même son code dans l'OPAC.

## Prérequis

* Koha **24.11** ou supérieur.
* Une instance Matomo accessible depuis le navigateur des usagers de l'OPAC
  dans laquelle un site a été créé pour l'OPAC. Notez son **ID de site**
  (Administration > Sites web > Gérer).

## Installation

**Activation des plugins** — Si ce n'est pas déjà fait, activez les plugins
dans Koha. Demandez à votre prestataire Koha de le faire, ou bien vérifiez que
`<enable_plugins>1</enable_plugins>` est présent dans `koha-conf.xml`.

**▼ TÉLÉCHARGEMENT ▼** — Récupérez sur le site [Tamil](https://www.tamil.fr)
l'archive du plugin **[Koha ⇄
Matomo](https://www.tamil.fr/download/koha-plugin-tamil-matomo-1.0.3.kpz)**.

**Installation** — Dans l'interface pro de Koha, allez dans Outils > Outils de
plugins. Cliquez sur Télécharger un plugin. Choisissez l'archive téléchargée à
l'étape précédente. Cliquez sur Télécharger.

## Configuration

Dans Outils > Outils de plugins, sur la ligne du plugin **Koha ⇄ Matomo**,
choisissez Actions > Configurer.

**Accès à Matomo**

* **URL du tracker** — Adresse de votre instance Matomo, sans `/` final ni nom
  de fichier, par exemple `https://stats.example.org`. La forme
  `//stats.example.org` permet de suivre le protocole de l'OPAC. Le plugin
  ajoute lui-même `/matomo.php` et `/matomo.js`.
* **ID du site** — Identifiant du site Matomo correspondant à l'OPAC.

**OPAC**

* **Activer le tracker à l'OPAC** — Tant que cette case n'est pas cochée,
  aucun code Matomo n'est envoyé à l'OPAC.
* **Titres des pages** — Libellés sous lesquels chaque type de page apparaît
  dans Matomo : Accueil, Recherche avancée, Résultat, Détail notice et Page
  statique. Les valeurs par défaut conviennent dans la plupart des cas.

L'enregistrement de la configuration prend effet immédiatement à l'OPAC.

## Données envoyées à Matomo

Le suivi ne porte que sur les pages suivantes de l'OPAC. Les autres pages
(compte usager, panier, etc.) ne sont pas suivies.

| Page OPAC | Ce qui est mesuré dans Matomo |
|-----------|-------------------------------|
| Accueil | Une page vue, sous le titre configuré. |
| Recherche avancée | Une page vue, sous le titre configuré. |
| Résultats de recherche | Une **recherche interne** (Comportement > Recherche interne) avec la requête de l'usager, et une page vue intitulée `<titre> : <requête>`. |
| Détail d'une notice | Un **événement** `Biblio` / `View` / `<biblionumber>`, une **impression de contenu** `Notice` / `<biblionumber> : <titre>`, une page vue intitulée `<titre> : <titre de la notice>` et le suivi des liens sortants. |
| Page éditoriale (`opac-page.pl`) | Une page vue intitulée `<titre> : <titre de la page>` et le suivi des liens sortants. |

Pour exploiter pleinement ces données dans Matomo :

* activez la **recherche interne** dans les paramètres du site, afin que les
  requêtes de l'OPAC apparaissent dans les rapports de recherche ;
* consultez les notices les plus vues dans Comportement > Événements
  (catégorie `Biblio`) ou Comportement > Contenus.

## Vie privée

Le plugin ne gère pas le consentement des usagers. Selon votre politique RGPD,
configurez Matomo en conséquence (anonymisation des adresses IP, suivi sans
cookie, etc.) ou conditionnez le suivi au consentement recueilli par Koha.

## Dépannage

* **Rien n'apparaît dans Matomo** — Vérifiez que la case Activer est cochée,
  que l'URL du tracker est correcte et que `<URL du tracker>/matomo.js` est
  accessible depuis un navigateur. Un bloqueur de publicité peut aussi
  empêcher le suivi.
* **Le code de suivi est absent de l'OPAC** — Vérifiez que le plugin est
  activé dans Outils de plugins. Le code est mis en cache côté Koha pendant une
  heure ; le cache est vidé à chaque enregistrement de la configuration.

## Versions

* **1.0.2** / oct. 2026 — Déploiement facilité.
* **1.0.1** / déc. 2025 — Version initiale.

## Licence

This software is copyright (c) 2025 by Tamil s.a.r.l..

This is free software; you can redistribute it and/or modify it under the same
terms as the Perl 5 programming language system itself.
