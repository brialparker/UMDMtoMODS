<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
  exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="collection">
        <mods:modsCollection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:mods="http://www.loc.gov/mods/v3"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates/>
        </mods:modsCollection>
    </xsl:template>

    <xsl:template match="item">
        <mods:mods>
            <xsl:apply-templates/>
        </mods:mods>
    </xsl:template>

    <xsl:template match="pid">
        <!-- because the MODS_xml_to_rdf.xsl expects the identifier to be type "modsIdentifier" in order to assign the URI of the resource -->
        <mods:identifier type="modsIdentifier">http://fedora.lib.umd.edu/fedora/get/<xsl:value-of select="."/></mods:identifier>
    </xsl:template>

    <xsl:template match="descMeta">
        <xsl:apply-templates select="title"/>
        <xsl:for-each select="agent[@type='creator'][persName/@xml:lang='ja']">
            <xsl:variable name="pos" select="position()"/>
            <mods:name type="personal" altRepGroup="{position()}">
                <mods:namePart>
                    <xsl:value-of select="persName"/>
                </mods:namePart> 
                <xsl:apply-templates select="." mode="roles"/>
            </mods:name>
            <mods:name altRepGroup="{position()}">
                <mods:namePart>
                    <xsl:value-of select="../agent[persName/@xml:lang='ja-Latn'][$pos]/persName"/>
                </mods:namePart> 
                <xsl:apply-templates select="." mode="roles"/>
            </mods:name>
        </xsl:for-each>
        <xsl:apply-templates select="agent[@type='creator']|agent[@type='contributor']"/>
        <xsl:for-each select="agent[@type='provider']">
            <xsl:if test="not(@role='publisher')">
                <mods:name>
                    <xsl:attribute name="type">
                        <xsl:if test="persName">
                            <xsl:text>personal</xsl:text>
                        </xsl:if>
                        <xsl:if test="corpName">
                            <xsl:text>corporate</xsl:text>
                        </xsl:if>
                    </xsl:attribute>
                    <mods:namePart>
                        <xsl:value-of select="."/>
                    </mods:namePart>
                    <xsl:apply-templates select="." mode="roles"/>
                </mods:name>
            </xsl:if>
        </xsl:for-each>
        <xsl:apply-templates select="mediaType"/>
        <xsl:apply-templates select="style"/>
        <mods:originInfo>
            <xsl:apply-templates select="agent[@role='publisher']"/>
            <xsl:apply-templates select="covTime/date | subject[@type='temporal']/date"/>
            <xsl:apply-templates select="covTime/dateRange"/>
            <xsl:apply-templates select="covPlace"/>
        </mods:originInfo>
        <xsl:apply-templates select="language"/>
        <xsl:apply-templates select="physDesc"/>
        <xsl:apply-templates select="description"/>
        <xsl:apply-templates select="subject"/>
        <xsl:apply-templates select="relationships/relation"/>
        <xsl:apply-templates select="identifier"/>
        <xsl:apply-templates select="repository"/>
        <xsl:apply-templates select="rights"/>
    </xsl:template>


    <xsl:template match="mediaType">
        <xsl:for-each select=".[@type]">
            <mods:typeOfResource>
                <xsl:if test="@type='sound'">
                    <xsl:text>sound recording</xsl:text>
                </xsl:if>
                <xsl:if test="@type='movingImage'">
                    <xsl:text>moving image</xsl:text>
                </xsl:if>
                <xsl:if test="@type='text'">
                    <xsl:text>text</xsl:text>
                </xsl:if>
                <xsl:if test="@type='image'">
                    <xsl:text>still image</xsl:text>
                </xsl:if>
                <xsl:if test="@type='collection'">
                    <xsl:attribute name="collection">yes</xsl:attribute>
                    <xsl:text>mixed material</xsl:text>
                </xsl:if>
                <xsl:if test="@type='event'">
                    <xsl:text>event</xsl:text>
                </xsl:if>
            </mods:typeOfResource>
        </xsl:for-each>
        <mods:genre>
            <xsl:value-of select="form"/>
        </mods:genre>
    </xsl:template>

    <xsl:template match="title">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test="@type='main'">
                    <xsl:choose>
                        <xsl:when test="@xml:lang='ja'">
                            <mods:titleInfo xml:lang="ja">
                                <mods:title>
                                    <xsl:value-of select="."/>
                                </mods:title>
                            </mods:titleInfo>
                        </xsl:when>
                        <xsl:when test="@xml:lang='ja-Latn'">
                            <mods:titleInfo type="translated" xml:lang="ja-Latn">
                                <mods:title>
                                    <xsl:value-of select="."/>
                                </mods:title>
                            </mods:titleInfo>
                        </xsl:when>
                        <xsl:otherwise>
                            <mods:titleInfo>
                                <mods:title>
                                    <xsl:value-of select="."/>
                                </mods:title>
                            </mods:titleInfo>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@type='alternate'">
                    <mods:titleInfo type="alternative">
                        <mods:title>
                            <xsl:value-of select="."/>
                        </mods:title>
                    </mods:titleInfo>
                </xsl:when>
                <xsl:otherwise>
                    <mods:titleInfo>
                        <mods:title>
                            <xsl:value-of select="."/>
                        </mods:title>
                    </mods:titleInfo>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
      
    <xsl:template match="agent[@type='creator']|agent[@type='contributor']">
        <xsl:choose>
             <xsl:when test="persName[not(@xml:lang='ja'or @xml:lang='ja-Latn')]">
                <mods:name type="personal">
                        <xsl:if test="persName[@xml:lang]">
                            <xsl:attribute name="xml:lang">
                                <xsl:copy>
                                    <xsl:value-of select="persName/@xml:lang"/>
                                </xsl:copy>
                            </xsl:attribute>
                        </xsl:if>
                        <mods:namePart>
                            <xsl:value-of select="persName"/>
                        </mods:namePart>
                    <xsl:apply-templates select="." mode="roles"/>
                    </mods:name>
                </xsl:when>
                <xsl:when test="corpName">
                    <mods:name>
                        <xsl:attribute name="type">
                            <xsl:text>corporate</xsl:text>
                        </xsl:attribute>
                        <mods:namePart>
                            <xsl:value-of select="corpName"/>
                        </mods:namePart>
                        <xsl:apply-templates select="." mode="roles"/>
                    </mods:name>
                </xsl:when>
            </xsl:choose>
    </xsl:template>

 <xsl:template match="agent[@role='publisher']">
        <mods:publisher>
            <xsl:if test="corpName[@xml:lang]">
                <xsl:attribute name="xml:lang">
                    <xsl:copy>
                        <xsl:value-of select="corpName/@xml:lang"/>
                    </xsl:copy>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="corpName"/>
        </mods:publisher>
    </xsl:template> 
    
    <xsl:template match="agent" mode="roles">
        <xsl:if test="@role='illustrator'">
            <mods:role>
                <mods:roleTerm type="text">Illustrator</mods:roleTerm>
                <mods:roleTerm type="code">ill</mods:roleTerm>
            </mods:role>
        </xsl:if>
        <xsl:if test="@role='author'">
            <mods:role>
                <mods:roleTerm type="text">Author</mods:roleTerm>
                <mods:roleTerm type="code">aut</mods:roleTerm>
            </mods:role>
        </xsl:if>
        <xsl:if test="@role='editor'">
            <mods:role>
                <mods:roleTerm type="text">Editor</mods:roleTerm>
                <mods:roleTerm type="code">edt</mods:roleTerm>
            </mods:role>
        </xsl:if>
        <xsl:if test="@role='publisher'">
            <mods:role>
                <mods:roleTerm type="text">Publisher</mods:roleTerm>
                <mods:roleTerm type="code">pbl</mods:roleTerm>
            </mods:role>
        </xsl:if>
        <xsl:if test="@type='provider'">
            <mods:role>
                <mods:roleTerm type="text">Provider</mods:roleTerm>
                <mods:roleTerm type="code">prv</mods:roleTerm>
            </mods:role>
        </xsl:if>
    </xsl:template>

    <xsl:template match="covTime/date | subject[@type='temporal']/date">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test=".[@certainty='circa']">
                    <mods:dateCreated qualifier="approximate">
                        <xsl:value-of select="."/>
                    </mods:dateCreated>
                </xsl:when>
                <xsl:when test=".[@certainty='exact']">
                    <mods:dateCreated>
                        <xsl:value-of select="."/>
                    </mods:dateCreated>
                </xsl:when>
                <xsl:otherwise>
                    <mods:dateCreated>
                        <xsl:value-of select="."/>
                    </mods:dateCreated>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="covTime/dateRange">

        <xsl:for-each select=".">
            <mods:dateOther>
                <xsl:if test=".[@from]">
                    <xsl:attribute name="point">
                        <xsl:text>start</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="./@from"/>
                </xsl:if>
            </mods:dateOther>
            <mods:dateOther>
                <xsl:if test=".[@to]">
                    <xsl:attribute name="point">
                        <xsl:text>end</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="./@to"/>
                </xsl:if>
            </mods:dateOther>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="covPlace">
        <xsl:for-each select=".">
            <!-- ideally this would be place of publication, so just a city,state,country. Currently the resulting xml displays in the order they appear, which I would like to change -->
            <mods:place>
                <mods:placeTerm type="text">
                    <xsl:call-template name="join">
                        <xsl:with-param name="list"
                            select="geogName[@type='settlement'] | geogName[@type='district'] | geogName[@type='region'] | geogName[@type='country']"/>
                        <xsl:with-param name="separator" select="', '"/>
                    </xsl:call-template>
                </mods:placeTerm>
            </mods:place>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="physDesc">
        <mods:physicalDescription>
            <xsl:for-each select="format">
            <mods:form>
                
                    <xsl:value-of select="."/>
                
            </mods:form>
            </xsl:for-each>
            <mods:extent>
                <xsl:for-each select="extent|size|color">
                    <xsl:value-of select=". | ./@units"/>
                    <xsl:if test="position() != last()">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </mods:extent>
            
                <xsl:for-each select="documents">
                    <mods:note>
                    <xsl:value-of select="."/>
                    <xsl:text> censorship document</xsl:text>
                    </mods:note>
                </xsl:for-each>
            
        </mods:physicalDescription>
    </xsl:template>

    <xsl:template match="description">
        <xsl:choose>
            <xsl:when test=".[@type='summary']">
                <mods:abstract displayLabel="summary">
                    <xsl:value-of select="."/>
                </mods:abstract>
            </xsl:when>
            <xsl:when test=".[@type='credits']">
                <mods:note type="creation/production credits">
                    <xsl:value-of select="."/>
                </mods:note>
            </xsl:when>
            <xsl:when test=".[@type='bibRef']">
                <mods:note type="acquisition">
                    <xsl:value-of
                        select="bibRef/imprint/availability/price | bibRef/imprint/availability/price/@units"/>
                    <!-- how to keep "yen" as price unit and stay valid? -->
                </mods:note>
            </xsl:when>
            <xsl:when test=".[@label='pcbcensorship']">
                <mods:note type="censorship">
                    <xsl:value-of select="."/>
                </mods:note>
            </xsl:when>

        </xsl:choose>
    </xsl:template>

    <xsl:template match="language">
        <xsl:for-each select=".">
            <mods:language>
                <mods:languageTerm type="code">
                    <xsl:value-of select="."/>
                </mods:languageTerm>
            </mods:language>

        </xsl:for-each>
    </xsl:template>

    <xsl:template match="identifier">
        <xsl:for-each select=".">
            <mods:identifier>
                <xsl:if test="@type">
                    <xsl:attribute name="type">
                        <xsl:copy>
                            <xsl:value-of select="./@type"/>
                        </xsl:copy>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="@label">
                    <xsl:attribute name="displayLabel">
                        <xsl:copy>
                            <xsl:value-of select="./@label"/>
                        </xsl:copy>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="repository">
        <xsl:for-each select="corpName">
            <mods:location>
                <mods:physicalLocation>
                    <xsl:if test=".[@xml:lang]">
                        <xsl:attribute name="xml:lang">
                            <xsl:copy>
                                <xsl:value-of select="./@xml:lang"/>
                            </xsl:copy>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </mods:physicalLocation>
            </mods:location>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="rights">
        <xsl:for-each select=".">
            <mods:accessCondition>
                <xsl:if test=".[@xml:lang]">
                    <xsl:attribute name="xml:lang">
                        <xsl:copy>
                            <xsl:value-of select="./@xml:lang"/>
                        </xsl:copy>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
            </mods:accessCondition>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="subject">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test=".[@scheme]">
                    <mods:subject>
                        <xsl:attribute name="authority">
                            <xsl:copy>
                                <xsl:value-of select="./@scheme"/>
                            </xsl:copy>
                        </xsl:attribute>
                        <mods:topic>
                            <xsl:value-of select="."/>
                        </mods:topic>
                    </mods:subject>
                </xsl:when>
                <xsl:when test=".[@type='temporal']/decade">
                    <xsl:for-each select="decade">
                        <mods:subject>
                            <mods:temporal>
                                <xsl:value-of select="."/>
                            </mods:temporal>
                        </mods:subject>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test=".[@type='geographical']">
                    <mods:subject>
                        <mods:hierarchicalGeographic>
                            <xsl:for-each select="./geogName">
                                <xsl:element name="mods:{@type}">
                                    <xsl:value-of select="."/>
                                </xsl:element>
                            </xsl:for-each>
                            <!-- the subelements probably aren't entirely valid for mods, but I have at least moved them... -->
                        </mods:hierarchicalGeographic>
                    </mods:subject>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="style">
        <xsl:for-each select=".">
            <mods:genre>
                <xsl:value-of select="."/>
            </mods:genre>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="relationships/relation">
           <xsl:choose>
            <xsl:when test=".[@label='citation']">
                
                    <mods:relatedItem>
                        <xsl:for-each select="bibRef/imprint">
                            <xsl:apply-templates select="title"/>
                            <xsl:apply-templates select="agent[@type='creator']|agent[@type='contributor']"/>
                        </xsl:for-each>
                        
                        <mods:originInfo>
                            <xsl:for-each select="bibRef/imprint/agent[@role='publisher']">
                            <xsl:apply-templates select="agent[@role='publisher']"/>
                            </xsl:for-each>
                           
                                <mods:place>
                                    <mods:placeTerm type="text">
                                        <xsl:for-each select="bibRef/imprint/geogName">
                                        <xsl:call-template name="join">
                                            <xsl:with-param name="list"
                                                select=".[@type='settlement'] | .[@type='district'] | .[@type='region'] | .[@type='country']"/>
                                            <xsl:with-param name="separator" select="', '"/>
                                            <!-- not sure why the separator isn't working here, or why I haven't been able to apply some templates -->
                                        </xsl:call-template>
                                        </xsl:for-each>
                                    </mods:placeTerm>
                                 </mods:place>
                        </mods:originInfo>
                          <mods:location>
                            <mods:holdingSimple>
                                <mods:copyInformation>
                                    <xsl:for-each select="bibRef/bibScope">
                                        <mods:shelfLocator>
                                            <xsl:if test=".[@type='series']">
                                                <xsl:text>Series </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                            <xsl:if test=".[@type='subseries']">
                                                <xsl:text>Subseries </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                            <xsl:if test=".[@type='box']">
                                                <xsl:text>Box </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                            <xsl:if test=".[@type='folder']">
                                                <xsl:text>Folder </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                            <xsl:if test=".[@type='item']">
                                                <xsl:text>Item </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                            <xsl:if test=".[@type='page']">
                                                <xsl:text>Page </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                            <xsl:if test=".[@type='accession']">
                                                <xsl:text>Accession </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:if>
                                        </mods:shelfLocator>
                                    </xsl:for-each>
                                </mods:copyInformation>
                            </mods:holdingSimple>
                            <!-- need to account for the rest of the bibScope info (such as collection, series, random numbers) and where it is/should go -->
                        </mods:location>
                        <xsl:for-each select=".">
                          <xsl:apply-templates select="identifier"/>
                        </xsl:for-each>
                    </mods:relatedItem>
             </xsl:when>
       
            <xsl:when test=".[@label='archivalcollection']">
                <mods:relatedItem>
                    <xsl:for-each select="bibRef">
                        <xsl:apply-templates select="title"/>
                        <xsl:apply-templates select="agent[@type='creator']|agent[@type='contributor']"/>
                    </xsl:for-each>
                    <mods:location>
                        <mods:holdingSimple>
                            <mods:copyInformation>
                                <xsl:for-each select="bibRef/bibScope">
                                    <mods:shelfLocator>
                                        <xsl:if test=".[@type='series']">
                                            <xsl:text>Series </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test=".[@type='subseries']">
                                            <xsl:text>Subseries </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test=".[@type='box']">
                                            <xsl:text>Box </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test=".[@type='folder']">
                                            <xsl:text>Folder </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test=".[@type='item']">
                                            <xsl:text>Item </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test=".[@type='page']">
                                            <xsl:text>Page </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                        <xsl:if test=".[@type='accession']">
                                            <xsl:text>Accession </xsl:text>
                                            <xsl:value-of select="."/>
                                        </xsl:if>
                                    </mods:shelfLocator>
                                </xsl:for-each>
                            </mods:copyInformation>
                        </mods:holdingSimple>
                       </mods:location>
                    
                </mods:relatedItem>
            </xsl:when>
            <xsl:when test=".[@type='requires']">
                <mods:relatedItem>
                    <mods:location>
                        <mods:holdingSimple>
                            <mods:copyInformation>
                                <mods:shelfLocator>
                                    <xsl:value-of select="description"/>
                                </mods:shelfLocator>
                            </mods:copyInformation>
                        </mods:holdingSimple>
                        <xsl:for-each select="extPtr">
                        <mods:url>
                            <xsl:value-of select="./@href"/>
                        </mods:url>
                        </xsl:for-each>
                    </mods:location>
                </mods:relatedItem>
            </xsl:when>
           <xsl:when test=".[@type='isPartOf']">
               <xsl:for-each select="./bibRef/series">
               <mods:relatedItem>
                   <mods:titleInfo>
                       <mods:title>
                           <xsl:value-of select="."/>
                       </mods:title>
                   </mods:titleInfo>
               </mods:relatedItem>
               </xsl:for-each>
           </xsl:when>
         </xsl:choose>

    </xsl:template>
    
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="culture"/>
    <xsl:template match="century"/>

    <xsl:template name="join">
        <xsl:param name="list"/>
        <xsl:param name="separator"/>
        <xsl:for-each select="$list">
            <xsl:value-of select="."/>
            <xsl:if test="position() != last()">
                <xsl:value-of select="$separator"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>