✉️ Shopify Email Compiler
Un système pour éditer, structurer et compiler proprement vos e-mails Shopify dans un repository Git, avec :

✅ Includes (header, footer, blocs)

✅ Traductions via fichiers YAML

✅ Versions multilingues (ex : en, ja)

✅ Compilation vers du HTML prêt à être copié-collé dans Shopify

✅ Liquid conservé, pour évaluation dynamique par Shopify

✅ Blocs personnalisés incluant des variables (with)

📁 Structure du projet

.
├── blocks/                  # Blocs HTML réutilisables (header, footer, date_jp...)
│   ├── header_en.liquid
│   ├── footer_en.liquid
│   ├── layout_en.liquid     # Layout principal (HTML head, body, etc.)
│   ├── layout_loops_en.liquid  # Layout alternatif pour emails "loop"
│   └── date_jp.liquid       # Bloc date localisée en japonais
│
├── locales/                 # Traductions YAML
│   ├── en.yml
│   └── ja.yml
│
├── templates/               # Contenu spécifique aux emails (1 par langue)
│   └── order_confirmation/
│       ├── en.liquid
│       └── ja.liquid
│
├── output/                  # HTML compilé (prêt à coller dans Shopify)
│   └── order_confirmation_en.html
│
├── build.rb                 # Script de compilation
└── README.md                # Ce fichier
🧱 Fichiers d’entrée
1. blocks/layout_XX.liquid
Le layout de base pour tous les e-mails. Doit inclure :


{% include 'styles.liquid' %}
{% include 'header_XX.liquid' %}
{{ content }}
{% include 'footer_XX.liquid' %}
💡 Une variable email_type est injectée automatiquement par le compilateur pour personnaliser le contenu par template.

2. templates/<email_type>/<lang>.liquid
Le contenu propre à un e-mail (ex: order_confirmation, order_invoice), dans la langue voulue.

Exemple :


<table>
  <tr>
    <td>
      <h1>{{ t.order_confirmation.title }}</h1>
      {% include 'date_jp.liquid' with attributes.Shipping-Date %}
    </td>
  </tr>
</table>
3. blocks/date_jp.liquid
Bloc dynamique de date au format japonais.

Utilisation :


{% include 'date_jp.liquid' with attributes.Shipping-Date %}
Contenu :


{% assign input_date = include %}
{% assign month = input_date | date: "%B" %}
{% assign month_jp = "" %}
{% case month %}
  {% when "January" %}   {% assign month_jp = "1月" %}
  ...
{% endcase %}
{{ input_date | date: "%Y年" }}{{ month_jp }}{{ input_date | date: "%d日" }}
4. locales/en.yml
Structure de traduction à clé dynamique :

yml
Copy
Edit
order_confirmation:
  title: "Thank you for your order!"
  iftext: "We'll email you again once your package ships."
  utm_campaign: "order_confirmation"
⚙️ Compilation
Lancer la compilation :

ruby build.rb
Cela va :

Injecter les blocs ({% include %}) statiquement

Injecter les variables de traduction {{ t.xxx }}

Conserver tout le Liquid utile (comme les filtres | date, assign, if, for, etc.)

Générer des fichiers HTML finalisés dans output/

🔍 Fonctionnement spécial include with
Ligne :


{% include 'date_jp.liquid' with attributes.Delivery-Date %}
Est transformée en :


{% assign include = attributes.Delivery-Date %}
...contenu de date_jp.liquid...
Tu peux donc passer des variables personnalisées à des blocs Liquid.

✅ Avantages
Compatible Shopify (Liquid conservé intact)

Facile à maintenir (modularité, DRY)

Compatible multilingue

Prêt pour être intégré à des workflows CI/CD si besoin

🧪 Tests recommandés
Vérifie la sortie dans output/

Copie-colle un fichier .html dans Shopify → Notifications

Fais un test d’envoi

✅ Teste bien les cas avec includes et traductions dynamiques
