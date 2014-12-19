<xsl:stylesheet
  xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:modsrdf="http://www.loc.gov/mods/rdf/v1#"
  xmlns:madsrdf="http://www.loc.gov/mads/rdf/v1#"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  version="1.0">

  <!-- inject Dublin Core elements into the modsrdf -->
  <!-- see also http://www.loc.gov/standards/mods/modsrdf-primer.html#dc -->

  <xsl:template match="modsrdf:titlePrincipal">
    <dc:title><xsl:value-of select="madsrdf:Title/rdfs:label"/></dc:title>
    <modsrdf:titlePrincipal>
      <xsl:apply-templates select="@*|node()"/>
    </modsrdf:titlePrincipal>
  </xsl:template>

  <xsl:template match="modsrdf:abstract">
    <dc:description><xsl:value-of select="."/></dc:description>
    <modsrdf:abstract>
      <xsl:apply-templates select="@*|node()"/>
    </modsrdf:abstract>
  </xsl:template>
  
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
