<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:exsl="http://exslt.org/common"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/"
  exclude-result-prefixes="xs" version="1.0">

  <xsl:output method="xml" indent="yes" />

  <xsl:template match="/descMeta">
    <mods:mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">

      <xsl:apply-templates select="*"></xsl:apply-templates>

    </mods:mods>
  </xsl:template>

  <xsl:template match="title">
    <mods:titleInfo>
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <!-- Catch all unhandled elements and ignore -->
  <xsl:template match="@* | node()" />

</xsl:stylesheet>