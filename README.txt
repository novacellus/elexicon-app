OGÓLNE
1. tłumaczenie
/modules/moje/i18n.xql --> i18n:text() tłumaczy żądany tekst

MAIN
1. Pole wyszukiwania:
- obsługuje modules/moje/scripts/moje.js związane z id #main_search_field, które przekazuje kwerendę do lemmaLookup.xql
2. Kwerendę obsługuje
- views/indexRedirect.xql proponuje formy i wysyła je do moje.js,
- moje.js po kliknięciu przesyła wybraną formę (?what) do singleView.html
 
 aaa