<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="xsl marc">

    <xsl:variable name="xs">http://www.w3.org/2001/XMLSchema#</xsl:variable>
    <xsl:variable name="madsrdf">http://www.loc.gov/mads/rdf/v1#</xsl:variable>
    
    <!-- subject thesaurus map -->
    <xsl:variable name="subjectThesaurus" select="document('map.xml')"/>
    
</xsl:stylesheet>