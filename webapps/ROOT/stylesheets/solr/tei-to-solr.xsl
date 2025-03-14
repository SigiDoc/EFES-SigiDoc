<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../kiln/stylesheets/solr/tei-to-solr.xsl" />

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 18, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> jvieira</xd:p>
      <xd:p>This stylesheet converts a TEI document into a Solr index document. It expects the parameter file-path,
      which is the path of the file being indexed.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:template match="/">
    <add>
      <xsl:apply-imports />
    </add>
  </xsl:template>
  <xsl:template match="tei:idno[@type = 'SigiDocID']" mode="facet_sigidoc_id_number">
    <field name="sigidoc_id_number">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  <xsl:template match="//tei:persName[@xml:lang='en']/tei:forename[ancestor::tei:listPerson/tei:person][text()]" 
    mode="facet_personal_names">
    <field name="personal_names">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  <xsl:template match="//tei:persName[@xml:lang='en']/tei:surname[ancestor::tei:listPerson/tei:person][text()]"
    mode="facet_family_names">
    <field name="family_names">
      <xsl:value-of select="."/>
    </field> 
  </xsl:template>
  <xsl:template match="//tei:listPerson/tei:person[@gender]"
    mode="facet_gender">
    <field name="gender">
      <xsl:choose>
        <xsl:when test="@gender = 'M'">
          <xsl:text>male</xsl:text>
        </xsl:when>
        <xsl:when test="@gender = 'F'">
          <xsl:text>female</xsl:text>
        </xsl:when>
        <xsl:when test="@gender = 'E'">
          <xsl:text>eunuch</xsl:text>
        </xsl:when>
        <xsl:when test="@gender = 'U'">
          <xsl:text>undetermined</xsl:text>
        </xsl:when>
      </xsl:choose>
    </field> 
  </xsl:template>
  <xsl:template match="//tei:div[@type='edition' and @subtype='editorial']/tei:div[@type='textpart' and (@n='obv' or @n='rev')]"
    mode="facet_language">
    <field name="language">
      <xsl:choose>
        <xsl:when test="@xml:lang = 'grc'">
          <xsl:text>Greek</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'la'">
          <xsl:text>Latin</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'la-Grek'">
          <xsl:text>Latin in Greek script</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-la'">
          <xsl:text>Greek and Latin</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-Latn'">
          <xsl:text>Greek in Latin script</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-Arab'">
          <xsl:text>Greek in Arabic script</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-ara'">
          <xsl:text>Greek and Arabic</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'ara-Grek'">
          <xsl:text>Arabic in Greek script</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-hye'">
          <xsl:text>Greek and Armenian</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'hye-Grek'">
          <xsl:text>Armenian in Greek script</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-syr'">
          <xsl:text>Greek and Syriac</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'syr-Grek'">
          <xsl:text>Syriac in Greek script</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'grc-kat'">
          <xsl:text>Greek and Georgian</xsl:text>
        </xsl:when>
        <xsl:when test="@xml:lang = 'kat-Grek'">
          <xsl:text>Georgian in Greek script</xsl:text>
        </xsl:when>
          <xsl:otherwise><xsl:text>undetermined</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field> 
  </xsl:template>
  <xsl:template match="tei:placeName[@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_place_names">
    <field name="place_names">
      <xsl:variable name="geography" select="doc('../../content/xml/authority/geography.xml')"/>
      <xsl:variable name="geo-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$geography//tei:place[@xml:id = $geo-id]//tei:placeName[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template match="tei:rs[@type = 'dignity'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_dignities">
    <field name="dignities">
      <xsl:variable name="dignities" select="doc('../../content/xml/authority/dignities.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$dignities//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template
    match="tei:rs[@type = 'office'][@subtype = 'civil'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_civil_offices">
    <field name="civil_offices">
      <xsl:variable name="offices" select="doc('../../content/xml/authority/offices.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$offices//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template
    match="tei:rs[@type = 'office'][@subtype = 'ecclesiastical'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_ecclesiastical_offices">
    <field name="ecclesiastical_offices">
      <xsl:variable name="offices" select="doc('../../content/xml/authority/offices.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$offices//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template
    match="tei:rs[@type = 'office'][@subtype = 'military'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_military_offices">
    <field name="military_offices">
      <xsl:variable name="offices" select="doc('../../content/xml/authority/offices.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$offices//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template match="tei:rs[@type = 'title'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_titles">
    <field name="titles">
      <xsl:variable name="titles" select="doc('../../content/xml/authority/titles.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$titles//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template
    match="tei:rs[@type = 'marianTerms'][@subtype][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_marian_terms">
    <field name="marian_terms">
      <xsl:variable name="appellatives" select="doc('../../content/xml/authority/appellatives.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$appellatives//tei:list[@type = 'marianTerms']//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template
    match="tei:rs[@type = 'christTerms'][@subtype][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_christ-related_terms">
    <field name="christ-related_terms">
      <xsl:variable name="appellatives" select="doc('../../content/xml/authority/appellatives.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$appellatives//tei:list[@type = 'christTerms']//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template
    match="tei:rs[@type = 'saintsTerms'][@subtype][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_saints-related_terms">
    <field name="saints-related_terms">
      <xsl:variable name="appellatives" select="doc('../../content/xml/authority/appellatives.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$appellatives//tei:list[@type = 'saintsTerms']//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  <xsl:template match="tei:figDesc[@n = 'whole'][@xml:lang = 'en']" mode="facet_iconography">
    <field name="iconography">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
<!--  <xsl:template match="tei:rs[@type = 'legendsCases'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_legend_case">
    <field name="legend_case">
      <xsl:variable name="cases" select="doc('../../content/xml/authority/legendsCases.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of select="$cases//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"/>
    </field>
  </xsl:template>
  -->
  <xsl:template match="tei:collection/tei:rs[@xml:lang = 'en']" mode="facet_collection">
    <field name="collection">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  <xsl:template match="tei:material/tei:seg[@xml:lang = 'en']" mode="facet_material">
    <field name="material">
      <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
    </field>
  </xsl:template>
  <xsl:template match="tei:objectType/tei:term/tei:seg[@xml:lang = 'en']" mode="facet_object_type">
    <field name="object_type">
      <xsl:value-of select="concat(lower-case(substring(., 1, 1)), substring(., 2))"/>
    </field>
  </xsl:template>
  <xsl:template match="tei:msIdentifier/tei:institution" mode="facet_holding_entity">
    <field name="holding_entity">
      <xsl:choose>
        <xsl:when test="normalize-space(.) != ''">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>no holding institution</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  <xsl:template match="//tei:div[@type = 'textpart']" mode="facet_metrical"> 
    <field name="metrical">
      <xsl:choose>
        <xsl:when test="//tei:div[@type = 'textpart']//tei:lg/@cert = 'low'">
          <xsl:text>uncertain</xsl:text>
        </xsl:when>
        <xsl:when test="//tei:div[@type = 'textpart']//tei:lg/@met">
          <xsl:text>yes</xsl:text>
        </xsl:when>
        <xsl:otherwise><xsl:text>no</xsl:text></xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  <xsl:template
    match="tei:div[@type='textpart' and @subtype='face' and starts-with(@rend, 'monogram')]"
    mode="facet_monogram">
    <field name="monogram">
      <xsl:choose>
        <xsl:when test="@rend = 'monogram-block'">
          <xsl:text>Block monogram</xsl:text>
        </xsl:when>
        <xsl:when test="@rend = 'monogram-cross'">
          <xsl:text>Cruciform monogram</xsl:text>
        </xsl:when>
        <xsl:when test="@rend = 'monogram-other'">
          <xsl:text>Other shape</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Unknown</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  <xsl:template
    match="tei:listPerson/tei:person/@role"
    mode="facet_milieu">
      <xsl:variable name="tokenize" select="tokenize(., ' ')"/>
      <xsl:for-each select="$tokenize">
        <field name="milieu">
          <xsl:variable name="normalized" select="replace(.,'-',' ')"/>
        <xsl:value-of select="$normalized"/>
        </field>
      </xsl:for-each>
  </xsl:template>
  <xsl:template match="tei:rs[@type = 'institution'][@ref][ancestor::tei:div/@type = 'textpart']"
    mode="facet_institutions">
    <field name="institutions">
      <xsl:variable name="institutions" select="doc('../../content/xml/authority/institutions.xml')"/>
      <xsl:variable name="ref-id" select="substring-after(@ref, '#')"/>
      <xsl:value-of
        select="$institutions//tei:item[@xml:id = $ref-id]//tei:term[@xml:lang = 'en']"
      />
    </field>
  </xsl:template>
  
  <xsl:template match="//tei:div[@type='translation']//tei:p[@xml:lang='en']" mode="facet_translation">
    <field name="translation">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  
  <xsl:template match="//tei:origDate//tei:seg[@xml:lang='en']" mode="facet_origDate">
    <field name="origdate">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  
  <!--
  <xsl:template match="//tei:collection//tei:rs[@xml:lang='en']" mode="facet_collection">
    <field name="origdate">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  -->
  

  <!-- This template is called by the Kiln tei-to-solr.xsl as part of
       the main doc for the indexed file. Put any code to generate
       additional Solr field data (such as new facets) here. -->
  
  <xsl:template name="extra_fields">
    <xsl:call-template name="field_sigidoc_id_number"/>
    <xsl:call-template name="field_place_names"/>
    <xsl:call-template name="field_dignities"/>
    <xsl:call-template name="field_civil_offices"/>
    <xsl:call-template name="field_ecclesiastical_offices"/>
    <xsl:call-template name="field_military_offices"/>
    <xsl:call-template name="field_institutions"/>
    <xsl:call-template name="field_marian_terms"/>
    <xsl:call-template name="field_christ-related_terms"/>
    <xsl:call-template name="field_saints-related_terms"/>
    <xsl:call-template name="field_iconography"/>
 <!--   <xsl:call-template name="field_legend_case"/> -->
    <xsl:call-template name="field_collection"/>
    <xsl:call-template name="field_holding_entity"/>
    <xsl:call-template name="field_personal_names"/>
    <xsl:call-template name="field_family_names"/>
    <xsl:call-template name="field_metrical"/>
    <xsl:call-template name="field_monogram"/>
    <xsl:call-template name="field_milieu"/>
    <xsl:call-template name="field_object_type"/>
    <xsl:call-template name="field_material"/>
    <xsl:call-template name="field_gender"/>
    <xsl:call-template name="field_language"/>
    <xsl:call-template name="field_translation"/>
    <xsl:call-template name="field_origDate"/>
    
  </xsl:template>
  
  <xsl:template name="field_sigidoc_id_number">
    <xsl:apply-templates mode="facet_sigidoc_id_number" select="//tei:idno[@type = 'SigiDocID']"/>
  </xsl:template>
  <xsl:template name="field_personal_names">
    <xsl:apply-templates mode="facet_personal_names"
      select="//tei:persName[@xml:lang='en']/tei:forename[ancestor::tei:listPerson/tei:person]"/>
  </xsl:template> 
  <xsl:template name="field_family_names">
    <xsl:apply-templates mode="facet_family_names"
      select="//tei:persName[@xml:lang='en']/tei:surname[ancestor::tei:listPerson/tei:person]"/>
  </xsl:template> 
  <xsl:template name="field_place_names">
    <xsl:apply-templates mode="facet_place_names"
      select="//tei:placeName[@ref][ancestor::tei:div/@type = 'textpart']"/>
  </xsl:template>
  <xsl:template name="field_dignities">
    <xsl:apply-templates mode="facet_dignities"
      select="//tei:rs[@type = 'dignity'][@ref][ancestor::tei:div/@type = 'textpart']"/>
  </xsl:template>
  <xsl:template name="field_civil_offices">
    <xsl:apply-templates mode="facet_civil_offices"
      select="//tei:rs[@type = 'office'][@subtype = 'civil'][@ref][ancestor::tei:div/@type = 'textpart']"
    />
  </xsl:template>
  <xsl:template name="field_ecclesiastical_offices">
    <xsl:apply-templates mode="facet_ecclesiastical_offices"
      select="//tei:rs[@type = 'office'][@subtype = 'ecclesiastical'][@ref][ancestor::tei:div/@type = 'textpart']"
    />
  </xsl:template>
  <xsl:template name="field_military_offices">
    <xsl:apply-templates mode="facet_military_offices"
      select="//tei:rs[@type = 'office'][@subtype = 'military'][@ref][ancestor::tei:div/@type = 'textpart']"
    />
  </xsl:template>
  <xsl:template name="field_titles">
    <xsl:apply-templates mode="facet_titles"
      select="//tei:rs[@type = 'title'][@ref][ancestor::tei:div/@type = 'textpart']"/>
  </xsl:template>
  <xsl:template name="field_marian_terms">
    <xsl:apply-templates mode="facet_marian_terms"
      select="//tei:rs[@type = 'marianTerms'][@subtype][@ref][ancestor::tei:div/@type = 'textpart']"
    />
  </xsl:template>
  <xsl:template name="field_christ-related_terms">
    <xsl:apply-templates mode="facet_christ-related_terms"
      select="//tei:rs[@type = 'christTerms'][@subtype][@ref][ancestor::tei:div/@type = 'textpart']"
    />
  </xsl:template>
  <xsl:template name="field_saints-related_terms">
    <xsl:apply-templates mode="facet_saints-related_terms"
      select="//tei:rs[@type = 'saintsTerms'][@subtype][@ref][ancestor::tei:div/@type = 'textpart']"
    />
  </xsl:template>
  <xsl:template name="field_iconography">
    <xsl:apply-templates mode="facet_iconography"
      select="//tei:figDesc[@n = 'whole'][@xml:lang = 'en']"/>
  </xsl:template>
<!-- <xsl:template name="field_legend_case">
    <xsl:apply-templates mode="facet_legend_case"
      select="//tei:rs[@type = 'legendsCases'][@ref][ancestor::tei:div/@type = 'textpart']"/>
  </xsl:template>
  -->
  <xsl:template name="field_collection">
    <xsl:apply-templates mode="facet_collection" select="//tei:collection/tei:rs[@xml:lang = 'en']"/>
  </xsl:template>
  <xsl:template name="field_material">
    <xsl:apply-templates mode="facet_material" select="//tei:material/tei:seg[@xml:lang = 'en']"/>
  </xsl:template>
  <xsl:template name="field_object_type">
    <xsl:apply-templates mode="facet_object_type" select="//tei:objectType/tei:term/tei:seg[@xml:lang = 'en']"/>
  </xsl:template>
  <xsl:template name="field_holding_entity">
    <xsl:apply-templates mode="facet_holding_entity"
      select="//tei:msIdentifier/tei:institution"/>
  </xsl:template>
  <xsl:template name="field_metrical"> 
    <xsl:apply-templates mode="facet_metrical" 
      select="//tei:div[@type = 'textpart']"/> 
  </xsl:template>
  <xsl:template name="field_monogram">
    <xsl:apply-templates mode="facet_monogram"
      select="//tei:div[@type='textpart' and @subtype='face' and starts-with(@rend, 'monogram')]"/>
  </xsl:template>
  <xsl:template name="field_milieu">
    <xsl:apply-templates mode="facet_milieu"
      select="//tei:listPerson/tei:person/@role"/>
  </xsl:template>
  <xsl:template name="field_institutions">
    <xsl:apply-templates mode="facet_institutions"
      select="//tei:rs[@type = 'institution'][@ref][ancestor::tei:div/@type = 'textpart']"/>
  </xsl:template>
  <xsl:template name="field_gender">
    <xsl:apply-templates mode="facet_gender"
      select="//tei:listPerson/tei:person[@gender]"/>
  </xsl:template>
  <xsl:template name="field_language">
    <xsl:apply-templates mode="facet_language"
      select="//tei:div[@type='edition' and @subtype='editorial']/tei:div[@type='textpart' and (@n='obv' or @n='rev')]"/>
  </xsl:template>
  
  <xsl:template name="field_translation">
    <xsl:apply-templates mode="facet_translation"
      select="//tei:div[@type='translation']//tei:p[@xml:lang='en']"/>
  </xsl:template>
  
  <xsl:template name="field_origDate">
    <xsl:apply-templates mode="facet_origDate"
      select="//tei:origDate//tei:seg[@xml:lang='en']"/>
  </xsl:template>
  
  
</xsl:stylesheet>
