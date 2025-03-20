<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of symbols in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl"/>

  <xsl:param name="index_type"/>
  <xsl:param name="subdirectory"/>
  <xsl:variable name="geography" select="doc('https://raw.githubusercontent.com/SigiDoc/authority/refs/heads/main/geography.xml')"/>

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select=".//tei:placeName[@ref][ancestor::tei:div/@type = 'textpart']"
        group-by="@ref">
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type"/>
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path"/>
          <field name="index_item_name">
            <xsl:variable name="geo-id" select="substring-after(@ref, '#')"/>
            <xsl:variable name="placenames">              
              <xsl:for-each select="$geography//tei:place[@xml:id = $geo-id]//tei:placeName">
                <name><xsl:value-of select="concat(./@xml:lang,'|',./text())"/></name>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of
              select="string-join($placenames/name, '-')"/>
          </field>
          <field name="index_ext_reference">
            <xsl:variable name="geo-id" select="substring-after(@ref, '#')"/>
            <xsl:variable name="geo-string">
              <xsl:for-each select="$geography//tei:place[@xml:id = $geo-id][tei:link]">
                <xsl:variable name="pleiades">
                  <xsl:value-of select="concat(tei:idno[@type = 'pleiades'],'_',tei:idno[@type='pleiades']/following-sibling::tei:link[contains(@target,'pleiades')]/@target)"/>
                </xsl:variable>
                <xsl:variable name="geonames">
                  <xsl:value-of select="concat(tei:idno[@type = 'geonames'],'_',tei:idno[@type='geonames']/following-sibling::tei:link[contains(@target,'geonames')]/@target)"/>
                </xsl:variable>
                <xsl:variable name="TIB">
                  <xsl:value-of select="concat(tei:idno[@type = 'TIB'], '_',tei:idno[@type='TIB']/following-sibling::tei:link[contains(@target,'tib')]/@target)"/>
                </xsl:variable>
                <xsl:variable name="test" select="."></xsl:variable>
                <val>
                  <xsl:value-of select="concat($pleiades,'|',$geonames,'|',$TIB)"/>    
                </val>
              </xsl:for-each>
            
            </xsl:variable>
            <xsl:value-of select="string-join($geo-string/val, '|')"/>
          </field>
          <xsl:apply-templates select="current-group()"/>
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>
  
  <xsl:template match="tei:placeName">
  <xsl:call-template name="field_index_instance_location"/>
  </xsl:template>
</xsl:stylesheet>
