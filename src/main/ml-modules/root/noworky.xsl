<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:date="http://exslt.org/dates-and-times"
                extension-element-prefixes="date"
                exclude-result-prefixes="xsl marc">

  <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
  <xsl:strip-space elements="*"/>

  <!--
      datestamp for generationProcess property of Work adminMetadata
      Useful to override if date:date-time() extension is not
      available
  -->
  <xsl:param name="pGenerationDatestamp">
    <xsl:choose>
      <xsl:when test="function-available('date:date-time')">
        <xsl:value-of select="date:date-time()"/>
      </xsl:when>
      <xsl:when test="function-available('current-dateTime')">
        <xsl:value-of select="current-dateTime()"/>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  
  <xsl:include href="vars.xsl"/>
  <xsl:include href="included.xsl"/>

  <xsl:template match="/">
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
             xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
             xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
             xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
             xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#">
      <xsl:apply-templates />
    </rdf:RDF>
  </xsl:template>

  <xsl:template match="marc:collection">
    <!-- pass marc:record nodes on down -->
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="marc:record">
    <xsl:variable name="recordno"><xsl:value-of select="position()"/></xsl:variable>
    <bf:Work>
        <bf:adminMetadata>
            <bf:AdminMetadata>
              <bf:generationProcess>
                <bf:GenerationProcess>
                  <xsl:if test="$pGenerationDatestamp != ''">
                    <bf:generationDate>
                      <xsl:attribute name="rdf:datatype"><xsl:value-of select="concat($xs,'dateTime')"/></xsl:attribute>
                      <xsl:value-of select="$pGenerationDatestamp"/>
                    </bf:generationDate>
                  </xsl:if>
                </bf:GenerationProcess>
              </bf:generationProcess>
            </bf:AdminMetadata>
        </bf:adminMetadata>
        <xsl:apply-templates mode="work" />
    </bf:Work>
  </xsl:template>

  <!-- suppress text from unmatched nodes -->
  <xsl:template match="text()" mode="work"/>
  
</xsl:stylesheet>
