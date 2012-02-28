<?xml version="1.0" encoding="UTF-8"?>

<!-- LGPLv3 <http://www.gnu.org/licenses/lgpl-3.0.txt> -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="ixsl" xmlns="http://www.w3.org/1999/xhtml" xmlns:a="http://ajax.org/2005/aml" version="2.0" exclude-result-prefixes="#all" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:op="http://robbertatwork.com/2012/operator" xmlns:js="http://saxonica.com/ns/globalJS" xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT" xmlns:style="http://saxonica.com/ns/html-style-property" xmlns:x="http://xslt2.org/extensions" xmlns:sig="http://xslt2.org/signature" xmlns:ev="http://www.w3.org/2001/xml-events" sig:value="1e91e6aa8e386" xmlns:m="http://www.w3.org/1998/Math/MathML">
  
  <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" name="html5"/>
  
  <xsl:output method="xhtml" encoding="UTF-8"/>
  
  <xsl:param name="time" select="seconds-from-dateTime(current-dateTime())"/>
  <xsl:param name="gridHeight" select="360"/>
  <xsl:param name="gridWidth" select="360"/>
  
  <xsl:template match="/">
    <html>
      <head>
        <title>Graph using CSS 3D Transforms</title>
        <link rel="stylesheet" type="text/css" href="./graph.css"/>
      </head>
      <body>
        <article>
          <h1>Frameless:<br/>XSLT&#160;2.0 for the web</h1>
          <xsl:apply-templates/>
          <xsl:call-template name="math"/>
          
          <xsl:if test="element-available('ixsl:schedule-instruction')">
            <ixsl:schedule-action wait="0">
              <xsl:call-template name="animate"/>
            </ixsl:schedule-action>
          </xsl:if>
        </article>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="a:chart">
    <xsl:param name="width" select="@width" as="xs:integer"/>
    <xsl:param name="height" select="@height" as="xs:integer"/>
    <xsl:param name="rotateX" select="64" as="xs:integer"/>
    <xsl:param name="rotateZ" select="0" as="xs:integer"/>
    <xsl:param name="anim" select="@anim" as="xs:integer"/>

    <div id="graph" class="ajaxorggraph graph graph3d" style="width: {$width}px; height: {$height}px;" data-zoom="1">
      <div class="graph-content" style="-webkit-transform: rotateX({$rotateX}deg); -moz-transform: rotateX({$rotateX}deg); -o-transform: rotateX({$rotateX}deg); -ms-transform: rotateX({$rotateX}deg);">
        <div class="xy-plane"/>
        <div class="grid" id="graph-content" style="width: {$gridWidth}px; height: {$gridHeight}px; -webkit-animation-duration: {$anim}s; -moz-animation-duration: {$anim}s; -o-animation-duration: {$anim}s; -ms-animation-duration: {$anim}s;">
          <xsl:apply-templates select="a:axis"/>
        </div>
      </div>
    </div>
  </xsl:template>
  
  <xsl:template match="a:axis">
    <xsl:param name="x1" select="@x1"/>
    <xsl:param name="x2" select="@x2"/>
    <xsl:param name="y1" select="@y1"/>
    <xsl:param name="y2" select="@y2"/>
    <xsl:param name="z1" select="@z1"/>
    <xsl:param name="z2" select="@z2"/>
    <xsl:param name="x3d" select="@x3d"/>
    <xsl:param name="y3d" select="@y3d"/>
    <xsl:param name="z3d" select="@z3d"/>
    <xsl:param name="mode" select="@mode"/>
    <xsl:param name="lockyzoom" select="@lockyzoom"/>
    <xsl:param name="orbity" select="@orbity"/>
    <xsl:param name="distance" select="@distance"/>
    <xsl:param name="orbitxanim" select="@orbitxanim"/>
    <xsl:param name="orbityanim" select="@orbityanim"/>
    <xsl:param name="orbitzanim" select="@orbitzanim"/>
    
    <xsl:variable name="rangeX" select="$x2 - $x1"/>
    <xsl:variable name="rangeY" select="$y2 - $y1"/>
    <xsl:variable name="rangeZ" select="$z2 - $z1"/>
    <xsl:variable name="originX" select="0"/>
    <xsl:variable name="originZ" select="0"/>
    
    <ol class="axis z-axis">
      <xsl:for-each select="op:to(xs:integer($x1), xs:integer($x2))">
        <li>
          <xsl:value-of select="."/>
        </li>
      </xsl:for-each>
    </ol>
    
    <xsl:apply-templates select="a:graph"/>
  </xsl:template>
  
  <xsl:template match="a:graph">
    <xsl:param name="steps" select="@steps" as="xs:integer"/>
    <xsl:variable name="minX" select="../@x1" as="xs:integer"/>
    <xsl:variable name="minZ" select="../@z1" as="xs:integer"/>
    <xsl:variable name="maxX" select="../@x2" as="xs:integer"/>
    <xsl:variable name="maxZ" select="../@z2" as="xs:integer"/>
    <xsl:variable name="originX" select="$gridWidth div 2"/>
    <xsl:variable name="originZ" select="$gridHeight div 2"/>
    <xsl:variable name="precisionX" select="0.25"/>
    <xsl:variable name="precisionZ" select="0.25"/>
    <xsl:variable name="square-width" select="$gridWidth div $steps"/>
    <xsl:variable name="square-height" select="$gridHeight div $steps"/>
    <xsl:variable name="stepsX" select="op:to(0, xs:integer(($maxX - $minX) div $precisionX) - 1)"/>
    <xsl:variable name="stepsZ" select="op:to(0, xs:integer(($maxZ - $minZ) div $precisionZ) - 1)"/>
    
    <xsl:for-each select="$stepsX">
      
      <xsl:variable name="gridX" select="current() - (0 - $minX) div $precisionX"/>
      <xsl:variable name="x" select="$gridX * $precisionX"/>
      <xsl:variable name="left" select="$originX + $gridX * $square-width"/>
      
      <xsl:for-each select="$stepsZ">
        
        <xsl:variable name="gridZ" select="current() - (0 - $minZ) div $precisionZ"/>
        <xsl:variable name="z" select="$gridZ * $precisionZ"/>
        <xsl:variable name="top" select="$originZ + $gridZ * $square-height"/>
        <xsl:variable name="y" select="js:formula($x, $z, $time)"/>
        
        <xsl:variable name="measure1" select="js:formula($x - 0.1, $z, $time)"/>
        <xsl:variable name="measure2" select="js:formula($x + 0.1, $z, $time)"/>
        <xsl:variable name="measure3" select="js:formula($x, $z - 0.1, $time)"/>
        <xsl:variable name="measure4" select="js:formula($x, $z + 0.1, $time)"/>
        
        <xsl:variable name="rotateX" select="x:choose($measure3 = $measure4, 0, x:choose($measure3 &lt; $measure4, 10, -10))"/>
        <xsl:variable name="rotateY" select="x:choose($measure1 = $measure2, 0, x:choose($measure1 &gt; $measure2, 10, -10))"/>
        <xsl:variable name="translateZ" select="xs:integer($y * 65)" as="xs:integer"/>
        
        <span tabindex="0" class="square" data-x="{$x}" data-z="{$z}" data-rotateX="{$rotateX}" data-rotateY="{$rotateY}" style="left: {$left}px; top: {$top}px; width: {$square-width}px; height: {$square-height}px; -moz-transform: rotateX({$rotateX}deg) rotateY({$rotateY}deg) translateZ({$translateZ}px); -webkit-transform: rotateX({$rotateX}deg) rotateY({$rotateY}deg) translateZ({$translateZ}px);"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template match="span" mode="ixsl:onclick">
  <!-- <xsl:template match="span" mode="ixsl:onclick" use-when="function-available('ixsl:event')"> -->
    <xsl:for-each select="x:id('selected-square')">
      <ixsl:set-attribute name="id" select="''"/>
    </xsl:for-each>
    <ixsl:set-attribute name="id" select="'selected-square'"/>
    <xsl:apply-templates select="x:id('selected-y')" mode="update-y"/>
  </xsl:template>
  
  <xsl:template match="*" mode="update-y">
    <xsl:result-document method="ixsl:replace-content" href="#selected-y">
      <xsl:choose>
        <xsl:when test="x:id('selected-square')">
          <xsl:apply-templates select="x:id('selected-square')" mode="value-y"/>
        </xsl:when>
        <xsl:otherwise>?</xsl:otherwise>
      </xsl:choose>
    </xsl:result-document>
  </xsl:template>
  
  <xsl:template match="*" mode="value-y">
    <xsl:value-of select="js:formula(xs:decimal(@data-x), xs:decimal(@data-z), seconds-from-dateTime(current-dateTime()))"/>
  </xsl:template>
  

  <xsl:template name="math">
    <math xmlns="http://www.w3.org/1998/Math/MathML" display='block'>
      <mrow>
        <mi>y</mi>
        <mo>=</mo>
        <mfrac>
            <mrow>
              <mo>sin</mo>
              <mo>&#x2061;</mo>
              <mo>(</mo>
              <msqrt>
                <mrow>
                  <msup><mi>x</mi><mn>2</mn></msup>
                  <mo>+</mo>
                  <msup><mi>z</mi><mn>2</mn></msup>
                </mrow>
              </msqrt>
              <mo>&#x22c5;</mo>
              <mn>3</mn>
              <mo>-</mo>
              <mn>2</mn>
              <mi>t</mi>
              <mo>)</mo>
            </mrow>
            <mrow>
              <msqrt>
                <mrow>
                  <msup><mi>x</mi><mn>2</mn></msup>
                  <mo>+</mo>
                  <msup><mi>z</mi><mn>2</mn></msup>
                </mrow>
              </msqrt>
              <mo>&#x22c5;</mo>
              <mn>3</mn>
              <mo>+</mo>
              <mn>0.3</mn>
          </mrow>
        </mfrac>
        <mo>=</mo>
        <mi id="selected-y">?</mi>
      </mrow>
    </math>
  </xsl:template>
  
  <xsl:template name="animate">
    <xsl:call-template name="animation-frame"/>
    <ixsl:schedule-action wait="0">
      <xsl:call-template name="animate"/>
    </ixsl:schedule-action>
  </xsl:template>
  
  <xsl:template name="animation-frame">
    <xsl:call-template name="ripple"/>
    <xsl:apply-templates select="x:id('selected-y')" mode="update-y"/>
  </xsl:template>
  
  <xsl:template name="ripple">
    <xsl:variable name="time" select="seconds-from-dateTime(current-dateTime())"/>
    <xsl:message select="x:class(ixsl:page(), 'square')"/>
    <xsl:for-each select="x:class(ixsl:page(), 'square')">
      <xsl:variable name="time" select="$time"/>
      <xsl:variable name="x" select="@data-x" as="xs:integer"/>
      <xsl:variable name="z" select="@data-z" as="xs:integer"/>
      <xsl:variable name="y" select="js:formula($x, $z, $time)"/>
      <xsl:variable name="measure1" select="js:formula($x - 0.1, $z, $time)"/>
      <xsl:variable name="measure2" select="js:formula($x + 0.1, $z, $time)"/>
      <xsl:variable name="measure3" select="js:formula($x, $z - 0.1, $time)"/>
      <xsl:variable name="measure4" select="js:formula($x, $z + 0.1, $time)"/>
      <xsl:variable name="rotateX" select="x:choose($measure3 &lt; $measure4, 10, x:choose($measure3 = $measure4, 0, -10))"/>
      <xsl:variable name="rotateY" select="x:choose($measure1 &gt; $measure2, 10, x:choose($measure1 = $measure2, 0, -10))"/>
      <ixsl:set-attribute name="style:-moz-transform" select="concat('rotateX(', $rotateX, 'deg) rotateY(', $rotateY, 'deg) translateZ(', $y * 65, 'px)')" use-when="x:css-property-available('-moz-transform')"/>
      <ixsl:set-attribute name="style:-webkit-transform" select="concat('rotateX(', $rotateX, 'deg) rotateY(', $rotateY, 'deg) translateZ(', $y * 65, 'px)')" use-when="x:css-property-available('-webkit-transform')"/>
      <ixsl:set-attribute name="style:-ms-transform" select="concat('rotateX(', @data-rotateX, 'deg) rotateY(', @data-rotateY, 'deg) translateZ(', $y * 65, 'px)')" use-when="x:css-property-available('-ms-transform')"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:include href="graph-fallback.xsl" use-when="not(system-property('xsl:vendor') = 'Robbert')"/>
  
</xsl:stylesheet>