.. _tutorial:

Tutorial
========

This tutorial walks you through the creation of a basic web site
edition of some historical letters.

Installation
------------

Installation of Kiln itself is simple. You can download a ZIP file of
all the code and unpack it, or use the Git version control system to
clone the repository. Either way, the code is available at the `Kiln
repository`_, and you'll end up with that code somewhere on your
filesystem.

You'll also need to have Java 1.7 installed. If it isn't on your
system already, you can download it from https://www.java.com/.

The development server
----------------------

Let's verify that the installation worked. From the command line, cd
into the directory where you installed Kiln. There, run the
``build.sh`` script (if you are running GNU/Linux or Mac OS X) or the
``build.bat`` batch file (if you are running Windows). You'll see the
following output on the command line::

    Buildfile: <path to your Kiln>/local.build.xml
    Development server is running at http://127.0.0.1:9999
    Quit the server with CONTROL-C.

You've started Jetty, a lightweight web server, that is pre-configured
to run all of the various Kiln components. Note that it may take a few
seconds after it prints out the above for the server to become
responsive.

Now that the server is running, visit http://127.0.0.1:9999/ with your
web browser. You'll see a "Welcome to Kiln" page.

.. note:: Changing the port

   By default, the ``build`` command starts the development server on
   the internal IP at port 9999.

   If you want to change the server's port, pass it as a command-line
   argument. For instance, this command starts the server on port
   8080::

      ./build.sh -Djetty.port=8080

   To change the default, edit the value of ``jetty.port`` in the file
   ``local.build.properties``.


Adding content
--------------

The main content of many Kiln sites is held in `TEI`_ XML files, so
let's add some.

QAZ

Now navigate to the text overview at http://127.0.0.1:9999/text/,
available as the Texts menu option. This presents a table with various
details of the texts in sortable columns. With only a homogenous
collection of a few letters, this is not very useful, but it does
provide links to the individual texts. Follow the link to the first
letter.


Customising the TEI display
---------------------------

Given the enormous flexibility of the TEI to express various
semantics, and the range of possible displays of a TEI document, there
is no one size fits all solution to the problem of transforming a TEI
document into HTML. Kiln comes with `XSLT`_ code that provides support
for some types of markup, but it is expected for each project to
either customise it or replace it altogether. Let's do the former.

Kiln uses the XSLT at ``webapps/ROOT/stylesheets/tei/to-html.xsl`` to
convert TEI into HTML. Open that file in your preferred XML editor. As
you can see, it is very short! All it does is import another XSLT,
that lives at ``webapps/ROOT/kiln/stylesheets/tei/to-html.xsl``. This
illustrates one of the ways that Kiln provides a separation between
Kiln's defaults and project-specific material. Rather than change the
XSLT that forms part of Kiln (typically, files that live in
``webapps/ROOT/kiln``), you change files that themselves import those
files. This way, if you upgrade Kiln and those files have changed,
you're not stuck trying me merge the changes you made back into the
latest file. And if you don't want to make use of Kiln's XSLT, just
remove the import.

.. note:: So how does Kiln know that we want to transform the TEI into
   HTML using this particular XSLT?

   This is specified in a Cocoon sitemap file, which defines the URLs
   in your site, and what to do, and to what, for each of them. In
   this case any request for a URL starting texts/ and ending in .html
   will result in the XML file with the same name being read from the
   filesystem, preprocessed, and then transformed using the
   to-html.xsl code.

   Sitemap files are discussed later in the tutorial.

Let's change the rendering so that...

Add this after the ``xsl:import`` element. Now reload the page showing
that text, and you'll see the text rerendered with...

.. warning:: Cocoon automatically caches the results of most requests,
   and invalidates that cache when it detects changes to the files
   used in creating the resource. Thus after making a change to
   ``to-html.xsl`` (the one in ``stylesheets/tei``, not the one in
   ``kiln/stylesheets/tei/``), reloading the text shows the effects of
   that change. However, Cocoon does not follow ``xsl:import`` and
   ``xsl:include`` references when checking for changed files. This
   means that if you change such an imported/included file, the cached
   version of the resource will be used.

   To ensure that the cache is invalidated in such cases, update the
   timestamp of the including file, or the source document. This can
   be done by re-saving the file (add a space, remove it, and save).


Adding images
.............


Searching and indexing
----------------------

Indexing
........

In order to provide any useful results, the search engine must index
the TEI documents. This functionality is made available in the `admin
section`_ of the site. You can either index each document
individually, or index them all at once.

There are two possible parts of customising the indexing: changing the
XSLT that specifies what information gets stored in which fields, and
changing the available fields.

The first is done by modifying the XSLT
``stylesheets/solr/tei-to-solr.xsl``. Just as with the TEI to HTML
transformation, this XSLT imports a default Kiln XSLT that can be
overridden.

To change the fields in the index, modify the Solr schema document at
``webapps/solr/conf/schema.xml``. Refer to the `Solr documentation`_
for extensive documentation on this and all other aspects of the Solr
search platform.

It would be useful to index the recipient of each letter, so that this
may be displayed as a facet in search results. In the ``fields``
element in ``schema.xml``, define a recipient field::

   <field indexed="true" multiValued="false" name="recipient"
          required="true" stored="true" type="string" />

After changing the schema, you will need to restart Jetty so that the
new configuration is loaded. You can check the schema that Solr is
using via the Solr admin interface at http://localhost:9999/solr/.

Next ``stylesheets/solr/tei-to-solr.xsl`` needs to modified to add in
the indexing of the recipient into the new schema. Looking at
``kiln/stylesheets/solr/tei-to-solr.xsl``, the default indexing XSLT
traverses through the teiHeader's descendant elements in the mode
``document-metadata``. It is a simple matter to add in a template to
match on the appropriate element::

   <xsl:template match="tei:profileDesc/tei:particDesc/tei:person[@role='recipient']"
                 mode="document-metadata">
     <field name="recipient">
       <xsl:value-of select="normalize-space()" />
     </field>
   </xsl:template>

Now reindex the letters.


Facets
......

To customise the use of facets, modify the XML file
``webapps/ROOT/assets/queries/solr/facet_query.xml``. This file
defines the base query that a user's search terms are added to, and
can also be used to customise all other parts of the query, such as
how many search results are displayed per page. The format is
straightforward; simply add elements with names matching the Solr
query parameters. You can have multiple elements with the same name,
and the query processor will construct it into the proper form for
Solr to interpret.

Add in a facet for the recipient field and perform a search. You can
see that the new facet is automatically displayed on the search
results page.


Results display
...............

The default results display is defined in
``stylesheets/solr/results-to-html.xsl`` and gives only the title of
the matching documents. Modify that XSLT to provide whatever format of
search results best suits your needs.


Building static pages
---------------------

Not all pages in a site need be generated dynamically from TEI
documents. Let's add an "About the project" page with the following
steps.

Adding a URL handler
....................

Each URL or set of URLs available in your web application is defined
in a Cocoon sitemap that specifies the source document(s), a set of
transformations to that document, and an output format for the
result. Sitemaps are XML files, and are best edited in an XML
editor. Open the file ``webapps/ROOT/sitemaps/main.xmap``.

The bulk of this file is the contents of the ``map:pipelines``
element, which holds several ``map:pipeline`` elements. In turn, these
hold the URL definitions that are the ``map:match`` elements. Each
``map:match`` has a ``pattern`` attribute that specifies the URL(s)
that it defines. This pattern can include wildcards, ``*`` and ``**``,
that match on any sequence of characters except ``/`` and any sequence
of characters, respectively.

The order of the ``map:match`` elements is important --- when a
request for a URL is handled by Kiln, it is processed using the first
``map:match`` whose pattern matches that URL. Then the child elements
of the ``map:match`` are executed (the XML here is all interpreted as
code) in order.

Go to the part of the document that defines the handler for the
``search/`` URL. Below that, add in a match for the URL
``about.html``. Since we'll be putting the content of the page we want
to return into the template (this is not the only way to do it!), our
source document is just the menu, and the only transformation is
applying the template. Your ``map:match`` should look something like the
following (and very similar to the one for the home page)::

   <map:match id="local-about" pattern="about.html">
     <map:aggregate element="aggregation">
       <map:part src="cocoon://_internal/menu/main.xml?url=about.html" />
     </map:aggregate>
     <map:transform src="cocoon://_internal/template/about.xsl" />
     <map:serialize />
   </map:match>

Even in such a short fragment there is a lot going
on. ``map:aggregate`` creates an XML document with a root element of
``aggregation``, containing one part (subelement). This part is the
product of internally making a request for the URL
``_internal/menu/main.xml?url=about.html``, which returns the menu
structure. The use of URLs starting with ``cocoon:/`` is common, and
allows a modular structure with lots of individual pieces that can be
put together. If you want to see the ``map:match`` that handles this
menu URL, open ``webapps/ROOT/kiln/sitemaps/main.xmap`` and look for
the ``kiln-menu`` pipeline.

The templating transformation, which puts the content of the
``aggregation`` element into a template, also internally requests a
URL. That URL returns the XML template file transformed into an XSLT
document, which is then applied to the source document!

Finally, the document is serialised; in this case no serializer is
specified, meaning that the default (HTML 5) is used.

Now that the ``about.html`` URL is defined, try requesting it at
http://localhost:9999/about.html. Not surprisingly, an error occurred,
because (as the first line of the stacktrace reveals) there is no
``about.xml`` template file. It's time to make one.


Adding a template
.................

Template files live in ``webapps/ROOT/assets/templates/``. They are
XML files, and must end in ``.xml``. In the ``map:match`` we just
created, the template was referenced at the URL
``cocoon://_internal/template/about.xsl`` --- there the ``xsl``
extension informally specifies the format of the document returned by
a request to that URL, but it reads the source file ``about.xml`` in
the templates directory. You can see how this works in the sitemap
file ``webapps/ROOT/kiln/sitemaps/main.xmap`` in the
``kiln-templating`` pipeline.

Create a new file, ``about.xml``, in the template directory. We could
define everything we want output in this file, but it's much better to
reuse the structure and style used by other pages on the site. Kiln
templates use a system of inheritance in which a parent template
defines arbitrary blocks of output that a child template can override
or append to. Open the ``base.xml`` file in the templates directory to
see the root template the default Kiln site uses. Mostly this is just
a lot of HTML, but wrapped into chunks via ``kiln:block``
elements. Now look at the ``tei.xml`` template, which shows how a
template can inherit from another and provide content only for those
blocks that it needs to.

Go ahead and add to ``about.xml`` (using ``tei.xml`` as a
basis) whatever content you want the "About the project" page to
have. Since there is no source document being transformed, there's no
need to have the ``xsl:import`` that ``tei.xml`` has, and wherever it
has ``xsl:value-of`` or ``xsl:apply-templates``, you should just put
in whatever text and HTML 5 markup you want directly.


Updating the menu
.................

In the ``map:match`` you created in ``main.xmap`` above, the
aggregated source document consisted only of a call to a URL
(``cocoon://_internal/menu/main.xml?url=about.htm``) to get a menu
document. In that URL, ``main.xml`` specifies the name of the menu
file to use, which lives in ``webapps/ROOT/assets/menu/``. Let's edit
that file to add in an entry for the new About page. This is easy to
do by just inserting the following::

   <menu href="about.html" label="About the project" />

Reload any of the pages of the site and you should now see the new
menu item. Obviously this menu is still very simple, with no
hierarchy. Read the :ref:`full menu documentation <navigation>` for
details on how to handle more complex setups.


Harvesting RDF
--------------

May look similar to Solr indexing, but add in a
mapping file for entities to Wikipedia URLs.


Development aids
----------------

The `admin section`_ provides a few useful tools for developers in
addition to the processes that can be applied to texts. The
`Introspection`_ section allows you to look at some of what Kiln is
doing when it runs.

*Match for URL* takes a URL and shows you the full Cocoon
``map:match`` that processes that URL. It expands all references, and
links to all XSLT, so that what can be scattered across multiple
sitemap files, with many references to ``*`` and ``**``, becomes a single
annotated piece of XML. Mousing over various parts of the output will
reveal details such as the sitemap file containing the line or the
values of wildcards.

Much the same display is available for each ``map:match`` that has an
ID, in *Match by ID*.

Finally, *Templates by filename* provides the expanded XSLT (all
imported and included XSLT are recursively included) for each
template, and how that template renders an empty document.


.. _admin section: http://127.0.0.1:9999/admin/
.. _Introspection: http://127.0.0.1:9999/admin/introspection/
.. _Kiln repository: https://github.com/kcl-ddh/kiln/
.. _Solr documentation: http://lucene.apache.org/solr/documentation.html
.. _TEI: http://www.tei-c.org/
.. _XSLT: http://www.w3.org/standards/xml/transformation