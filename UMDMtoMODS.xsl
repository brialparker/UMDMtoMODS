<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="doc/str">
        <xsl:for-each select="descMeta">
            <mods:mods
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
                <xsl:apply-templates/>
            </mods:mods>
        </xsl:for-each>
    </xsl:template>
    
     <xsl:template match="mediaType">
        <xsl:for-each select=".[@type]">
            <mods:typeOfResource>
                <xsl:if test="@type='sound'"><xsl:text>sound recording</xsl:text></xsl:if>
                <xsl:if test="@type='movingImage'"><xsl:text>moving image</xsl:text></xsl:if>
                <!-- how will we handle ones that are actually sound recordings, not moving images? -->
                <xsl:if test="@type='text'"><xsl:text>text</xsl:text></xsl:if>
                <xsl:if test="@type='image'"><xsl:text>still image</xsl:text></xsl:if>
                <xsl:if test="@type='collection'"><xsl:attribute name="collection">yes</xsl:attribute><xsl:text>mixed material</xsl:text></xsl:if>
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
                         <mods:titleInfo type="translated" xml:Lang="ja-Latn">
                             <mods:title>
                                 <xsl:value-of select="."/>
                             </mods:title>
                         </mods:titleInfo>
                     </xsl:when>
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
      <xsl:for-each select=".[@type='creator']|.[@type='contributor']">
            <xsl:choose>
                <xsl:when test="persName">
                    <mods:name>
                       <xsl:attribute name="type">
                           <xsl:text>personal</xsl:text>
                       </xsl:attribute>
                       <!-- how to copy over xml:lang attribute when it appears? -->
                    <xsl:value-of select="persName"/>
                    </mods:name>
                </xsl:when>
                <xsl:when test="corpName">
                    <mods:name>
                        <xsl:attribute name="type">
                            <xsl:text>corporate</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="corpName"/>
                    </mods:name>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- map publisher to mods:originInfo/publisher element. Need to create templates to enable combining publisher, date, publication location under originInfo -->
      <xsl:template match="agent[@role='publisher']">
           <xsl:for-each select=".[@role='publisher']">
               <xsl:choose>
                   <xsl:when test="@role='publisher'">
                    <mods:originInfo>
                        <mods:publisher>
                            <xsl:value-of select="."/>
                        </mods:publisher>
                     </mods:originInfo>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each> 
    </xsl:template>
    
  
    <xsl:template match="covTime | subject[@type='temporal']">
        <xsl:for-each select="date">
            <xsl:choose>
                <xsl:when test="date[@certainty='circa']">
                  <mods:dateCreated qualifier="approximate">
                     <xsl:value-of select="."/>
                    </mods:dateCreated>
                </xsl:when> 
                <xsl:when test="date[@certainty='exact']">
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
    
    <xsl:template match="covPlace">
        <xsl:for-each select=".">

                <mods:place>
                    <mods:placeTerm type="text">
                        <xsl:call-template name="join">
                            <xsl:with-param name="list" select="geogName" />
                            <xsl:with-param name="separator" select="', '" />
                        </xsl:call-template>
                    </mods:placeTerm>
                </mods:place>
<!-- preliminary work - this needs to go within mods:originInfo with publisher and dateCreated -->
        </xsl:for-each>
    </xsl:template>
    
    <!-- need to decide what to do with form. do we match them to LOC genre terms (not always an exact match)? Need to find out what forms are in use currently in Fedora and go from there. -->

 <xsl:template match="physDesc">
     
     <mods:physicalDescription>
         <xsl:for-each select=".">
        <mods:extent>
            <xsl:call-template name="join">
                <xsl:with-param name="list" select="extent | extent[@units/text()] | size | size[@units/text()]"/>
                <xsl:with-param name="separator" select="', '" />
            </xsl:call-template>
        </mods:extent>
             <!-- cannot figure out how to get the extent and size units to appear at the moment -->
         </xsl:for-each>
         <xsl:for-each select="format">
         <mods:format>
             <xsl:value-of select="."/>
         </mods:format>
            
        </xsl:for-each>
     </mods:physicalDescription>
 </xsl:template>    

<xsl:template match="description">
    <xsl:choose>
        <xsl:when test=".[@type='summary']">
        <mods:abstract display-label="summary">
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
            <xsl:value-of select="bibRef/imprint/availability/price"/>
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
                <xsl:value-of select="."/>
            </mods:identifier>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="repository">
        <xsl:for-each select="corpName">
            <mods:location>
                <mods:physicalLocation>
                    <xsl:value-of select="."/>
                </mods:physicalLocation>
            </mods:location>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="culture">
        <xsl:for-each select="."/>
      </xsl:template>
    <xsl:template match="rights">
        <xsl:for-each select=".">
            <mods:accessCondition>
                <xsl:value-of select="."/>
            </mods:accessCondition>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="subject">
        <xsl:for-each select=".">
            <xsl:choose>
                <xsl:when test=".[@scheme='LCSH']">
                          <mods:subject>
                   <xsl:attribute name="authority">
                            <xsl:text>lcsh</xsl:text>
                        </xsl:attribute>
                              <mods:topic>
                        <xsl:value-of select="."/>
                                 </mods:topic>
                    </mods:subject>
                </xsl:when>
                <xsl:when test=".[@type='temporal']">
                    <mods:subject>
                        <mods:temporal>
                            
                            <xsl:value-of select="decade"/>
                        </mods:temporal>
                    </mods:subject>
                </xsl:when>
                <xsl:when test=".[@type='geographical']">
                    <!-- need to evaluate if these are all in fact geographical subjects, or if they duplicate covPlace -->
                    <mods:subject>
                        <mods:geographic>
                            <xsl:call-template name="join">
                                <xsl:with-param name="list" select="geogName" />
                                <xsl:with-param name="separator" select="', '" />
                            </xsl:call-template>
                        </mods:geographic>
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
    
    <xsl:template match="relationships">
        <xsl:for-each select="relation">
            <xsl:choose>
                <xsl:when test=".[@label='citation']">
                    <mods:relatedItem>
                        <mods:title>
                            <xsl:value-of select="./bibRef/title"/>
                        </mods:title>
                        <!-- should I be able to apply templates here for agent, geogname, etc., that appear in the citation? -->
                    </mods:relatedItem>
                </xsl:when>
                <xsl:when test=".[@label='archivalcollection']">
                    <mods:relatedItem>
                        <mods:title>
                            <xsl:value-of select="./bibRef/title"/>
                        </mods:title>
                        <mods:location>
                             <mods:holdingSimple>
                                 <mods:copyInformation>
                                     <mods:shelfLocator>
                                 <xsl:for-each select="./bibRef/bibScope">
                                     <xsl:if test=".[@type='series']">
                                         <xsl:text>Series </xsl:text><xsl:value-of select="."/><xsl:text>, </xsl:text>
                                     </xsl:if>
                                         <xsl:if test=".[@type='subseries']">
                                             <xsl:text>Subseries </xsl:text><xsl:value-of select="."/><xsl:text>, </xsl:text>
                                         </xsl:if>   
                                        <xsl:if test=".[@type='box']">
                                 <xsl:text>Box </xsl:text><xsl:value-of select="."/><xsl:text>, </xsl:text>
                                 </xsl:if>
                                     <xsl:if test=".[@type='folder']">
                                         <xsl:text>Folder </xsl:text><xsl:value-of select="."/><xsl:text>, </xsl:text>
                                     </xsl:if>
                                     <xsl:if test=".[@type='item']">
                                         <xsl:text>Item </xsl:text><xsl:value-of select="."/><xsl:text>, </xsl:text>
                                     </xsl:if>
                                     <xsl:if test=".[@type='accession']">
                                 <xsl:text>Accession </xsl:text><xsl:value-of select="."/>
                                     </xsl:if>
                                    </xsl:for-each>
                                     </mods:shelfLocator>
                                 </mods:copyInformation>
                             </mods:holdingSimple>
                            <!-- need to account for the rest of the bibScope info (such as collection, series, random numbers) and where it is/should go -->
                        </mods:location>
                    </mods:relatedItem>
                </xsl:when>
           <xsl:otherwise>
            <mods:relatedItem>
                <mods:title>
                    <xsl:value-of select="./bibRef/title"/>
                </mods:title>
            </mods:relatedItem>
           </xsl:otherwise>
            </xsl:choose>
           
        </xsl:for-each>
    </xsl:template>

        
    
    <xsl:template name="join">
        <xsl:param name="list" />
        <xsl:param name="separator"/>
        
        <xsl:for-each select="$list">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$separator" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- can't find a MODS element that works for mapping price (which is used in Prange). There is one in MARC, but not in MODS. May just have to put into a generic notes field? -->
</xsl:stylesheet>