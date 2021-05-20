# Projektplan

## 1. Projektbeskrivning (Beskriv vad sidan ska kunna göra).
Jag ska skapa en blogg sida där man ska kunna skapa ett konto, logga in och publicera bloggar. Dessa ska vara i form av text men man ska även kunna inkludera länkar/bilder.
Sidan ska även tillåta en att se andra profilers bloggar där man ska kunna likea/kommentera. Sen eventuellt(kanske) ska man även kunna se alla bloggar man likeat eller kunna se
alla bloggar listade i antal likes/kommentarer.

## 2. Vyer (visa bildskisser på dina sidor).
https://gyazo.com/d1eccd0f962c74b961efc9a4dcb7e77b

## 3. Databas med ER-diagram (Bild på ER-diagram).

## 4. Arkitektur (Beskriv filer och mappar - vad gör/innehåller de?).
Jag har 8 mappar och 3 filer. De 3 filerna är app.rb, som innehåller mina gets och posts och formar hela websidan. Gemfile är endast till för yardoc och OLD_app.rb är som sagt gammal.

Mappar:
 - .yardoc: är endast yardocs automatiskt skapade saker
 - db: innehåller min databas
 - doc: yardocs automatiskt skapade filer som visar den nuvarande dokumentationen
 - img: ER-diagram + skisser
 - misc: övriga uppgiftsbeskrivningar
 - model: innehåller min model.rb fil där alla funktioner som bland annat involverar databasen används och bli kallade i app.rb
 - public: css-filen "style.css"
 - Views: Alla slim filer
    - my_blogs: alla slim filer som involverar bloggar. Där finns slim filerna där jag kan kolla på mina bloggar, alla bloggar, läsa specifika bloggar, bloggar som filtreras med en genre, skapa/uppdatera/ta bort mina bloggar, etc.
    Det som är utanför my_blogs är min error.slim fil som visar alla error meddelanden. Layout.slim som är min "huvud-sida". Login.slim som visar login sidan och register.slim som visar sidan där man skapar sitt konto



