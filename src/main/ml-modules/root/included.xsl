<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:bf="http://id.loc.gov/ontologies/bibframe/"
                xmlns:bflc="http://id.loc.gov/ontologies/bflc/"
                xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc">

  <xsl:template match="marc:datafield[@tag='648' or (@tag='880' and substring(marc:subfield[@code='6'],1,3)='648')] |
                       marc:datafield[@tag='650' or (@tag='880' and substring(marc:subfield[@code='6'],1,3)='650')] |
                       marc:datafield[@tag='651' or (@tag='880' and substring(marc:subfield[@code='6'],1,3)='651')] |
                       marc:datafield[@tag='655' or (@tag='880' and substring(marc:subfield[@code='6'],1,3)='655')][@ind1=' ']"
                mode="work">
    <xsl:param name="recordid" select="123456" />
    <xsl:param name="pPosition" select="position()"/>
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="pHasItem" select="false()"/>
    <!-- note special $5 processing for LoC below -->
    <!-- special processing only for 655 -->
    <xsl:if test="@tag != '655' or $pHasItem">
      <xsl:variable name="vDefaultUri">
        <xsl:choose>
          <xsl:when test="@tag='648'">
            <xsl:value-of select="$recordid"/>#Temporal<xsl:value-of select="@tag"/>-<xsl:value-of select="$pPosition"/>
          </xsl:when>
          <xsl:when test="@tag='651'">
            <xsl:value-of select="$recordid"/>#Place<xsl:value-of select="@tag"/>-<xsl:value-of select="$pPosition"/>
          </xsl:when>
          <xsl:when test="@tag='655'">
            <xsl:value-of select="$recordid"/>#GenreForm<xsl:value-of select="@tag"/>-<xsl:value-of select="$pPosition"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$recordid"/>#Topic<xsl:value-of select="@tag"/>-<xsl:value-of select="$pPosition"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="vTopicUri">
        <xsl:apply-templates mode="generateUri" select=".">
          <xsl:with-param name="pDefaultUri" select="$vDefaultUri"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:apply-templates select="." mode="work6XXAuth">
        <xsl:with-param name="pTopicUri" select="$vTopicUri"/>
        <xsl:with-param name="recordid" select="$recordid"/>
        <xsl:with-param name="serialization" select="$serialization"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  

  <xsl:template match="marc:datafield" mode="work6XXAuth">
    <xsl:param name="serialization" select="'rdfxml'"/>
    <xsl:param name="recordid"/>
    <xsl:param name="pTopicUri"/>
    <xsl:variable name="vTag">
      <xsl:choose>
        <xsl:when test="@tag='880'"><xsl:value-of select="substring(marc:subfield[@code='6'],1,3)"/></xsl:when>
        <xsl:otherwise><xsl:value-of select="@tag"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vProp">
      <xsl:choose>
        <xsl:when test="$vTag='655'">bf:genreForm</xsl:when>
        <xsl:otherwise>bf:subject</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vResource">
      <xsl:choose>
        <xsl:when test="$vTag='648'">bf:Temporal</xsl:when>
        <xsl:when test="$vTag='651'">bf:Place</xsl:when>
        <xsl:when test="$vTag='655'">bf:GenreForm</xsl:when>
        <xsl:otherwise>bf:Topic</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vSourceURI"><xsl:value-of select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/bfsource"/></xsl:variable>
    <xsl:variable name="vSourceCode"><xsl:value-of select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/code"/></xsl:variable>
    <xsl:variable name="vMADSClass">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code='v' or @code='x' or @code='y' or @code='z']">ComplexSubject</xsl:when>
        <xsl:when test="$vTag='648'">Temporal</xsl:when>
        <xsl:when test="$vTag='650'">
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='b' or @code='c' or @code='d']">ComplexSubject</xsl:when>
            <xsl:otherwise>Topic</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='651'">
          <xsl:choose>
            <xsl:when test="marc:subfield[@code='b']">ComplexSubject</xsl:when>
            <xsl:otherwise>Geographic</xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$vTag='655'">Topic</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$serialization = 'rdfxml'">
        <xsl:element name="{$vProp}">
          <xsl:element name="{$vResource}">
            <xsl:attribute name="rdf:about"><xsl:value-of select="$pTopicUri"/></xsl:attribute>
            <rdf:type>
              <xsl:attribute name="rdf:resource"><xsl:value-of select="concat($madsrdf,$vMADSClass)"/></xsl:attribute>
            </rdf:type>
            <xsl:for-each select="$subjectThesaurus/subjectThesaurus/subject[@ind2=current()/@ind2]/madsscheme">
              <madsrdf:isMemberOfMADSScheme>
                <xsl:attribute name="rdf:resource"><xsl:value-of select="."/></xsl:attribute>
              </madsrdf:isMemberOfMADSScheme>
            </xsl:for-each>

            <xsl:choose>
              <xsl:when test="$vSourceCode != '' or $vSourceURI != ''">
                <bf:source>
                  <bf:Source>
                    <xsl:if test="$vSourceURI != ''">
                      <xsl:attribute name="rdf:about"><xsl:value-of select="$vSourceURI"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="$vSourceCode != ''">
                      <bf:code><xsl:value-of select="$vSourceCode"/></bf:code>
                    </xsl:if>
                  </bf:Source>
                </bf:source>
              </xsl:when>
            </xsl:choose>

          </xsl:element>
        </xsl:element>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  
  <!--
      generate agent or work URI from 1XX, 6XX, 7XX, or 8XX, taking $0 or $w into account
      generated URI will come from the first URI in a $0 or $w
  -->
  <xsl:template match="marc:datafield" mode="generateUri">
    <xsl:param name="pDefaultUri"/>
    <xsl:param name="pEntity"/>
    <xsl:variable name="vGeneratedUri">
      <xsl:choose>
        <xsl:when test="marc:subfield[@code='t']">
          <xsl:variable name="vIdentifier">
            <xsl:choose>
              <xsl:when test="$pEntity='bf:Agent'">
                <xsl:value-of select="marc:subfield[@code='t']/preceding-sibling::marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')][1]"/>
              </xsl:when>
              <xsl:when test="$pEntity='bf:Work'">
                <xsl:value-of select="marc:subfield[@code='t']/following-sibling::marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')][1]"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="starts-with($vIdentifier,'(uri)')">
              <xsl:value-of select="substring-after($vIdentifier,'(uri)')"/>
            </xsl:when>
            <xsl:when test="starts-with($vIdentifier,'http')">
              <xsl:value-of select="$vIdentifier"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="vIdentifier">
            <xsl:value-of select="marc:subfield[@code='0' or @code='w'][starts-with(text(),'(uri)') or starts-with(text(),'http')][1]"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="starts-with($vIdentifier,'(uri)')">
              <xsl:value-of select="substring-after($vIdentifier,'(uri)')"/>
            </xsl:when>
            <xsl:when test="starts-with($vIdentifier,'http')">
              <xsl:value-of select="$vIdentifier"/>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$vGeneratedUri != ''"><xsl:value-of select="$vGeneratedUri"/></xsl:when>
      <xsl:otherwise><xsl:value-of select="$pDefaultUri"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

