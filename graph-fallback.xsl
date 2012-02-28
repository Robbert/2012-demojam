<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:a="http://ajax.org/2005/aml" version="2.0" exclude-result-prefixes="#all" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:op="http://robbertatwork.com/2012/operator" xmlns:js="http://saxonica.com/ns/globalJS" xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT" xmlns:style="http://saxonica.com/ns/html-style-property" xmlns:x="http://xslt2.org/extensions" xmlns:sig="http://xslt2.org/signature" xmlns:ev="http://www.w3.org/2001/xml-events" sig:value="1e91e6aa8e386" xmlns:internal="urn:internal">
  
  <!-- getElementsByClassName() equivalent -->
  <xsl:function name="x:class" use-when="not(function-available('x:class')) and function-available('ixsl:page')">
    <xsl:param name="className"/>
    <xsl:sequence select="ixsl:page()//*[@class cast as xs:NMTOKENS = $className]"/>
  </xsl:function>

  <!-- getElementsByClassName() equivalent -->
  <xsl:function name="x:class" use-when="not(function-available('x:class')) and not(function-available('ixsl:page'))">
    <xsl:param name="contextItem"/>
    <xsl:param name="className"/>
    
    <!-- This implementation isn't complete, but it works for my uses -->
    <xsl:sequence select="$contextItem//*[@class = $className or starts-with(@class, concat($className, ' ')) or ends-with(@class, concat(' ', $className))]"/>
  </xsl:function>
  
  <xsl:function name="x:class" use-when="not(function-available('x:class')) and system-property('xsl:is-schema-aware') eq 'yes'">
    <xsl:param name="contextItem"/>
    <xsl:param name="className"/>
    <xsl:sequence select="$contextItem//*[xs:NMTOKENS(@class) = $className]"/>
  </xsl:function>

  <xsl:function name="x:id" use-when="not(function-available('x:id'))">
    <xsl:param name="idref"/>
    <xsl:sequence select="()"/>
  </xsl:function>

  <xsl:function name="ixsl:page" use-when="not(function-available('ixsl:page'))">
    <xsl:sequence select="()"/>
  </xsl:function>

  <!-- Until XPath 2.0 sequence notation is supported. -->
  <xsl:function name="x:max" use-when="not(function-available('x:max'))">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:sequence select="max(($a, $b))"/>
  </xsl:function>

  <!-- Until XPath 2.0 sequence notation is supported. -->
  <xsl:function name="x:min" use-when="not(function-available('x:min'))">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:sequence select="min(($a, $b))"/>
  </xsl:function>

  <!-- Although there is an overhead to using wrapped JavaScript functions,
       using a native implementation is faster and should be used to boost
       framerates and lower CPU usage.
  -->
  <xsl:function name="js:formula" use-when="not(function-available('js:formula'))">
    <xsl:param name="x"/>
    <xsl:param name="z"/>
    <xsl:param name="t"/>
    <xsl:variable name="e" select="math:sqrt(math:pow($x, 2) + math:pow($z, 2) * 3)"/>
    <xsl:variable name="partialY" select="math:sin($e - 2 * $t)"/>
    <xsl:variable name="y" select="$partialY div ($e + 0.3)"/>
    <xsl:sequence select="$y"/>
    <!-- var __e, z = Math.sin((__e = Math.sqrt(x * x + z * z) * 3) - 2 * t) / (__e + 0.3); -->
  </xsl:function>

  <!-- Until XPath 2.0 the to operator notation is supported. -->
  <xsl:function name="op:to" use-when="not(function-available('op:to'))">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:sequence select="$a to $b"/>
  </xsl:function>

  <!-- Until XPath 2.0 if/else is supported. -->
  <xsl:function name="x:choose" use-when="not(function-available('x:choose'))">
    <xsl:param name="condition"/>
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:sequence select="if ($condition) then $a else $b"/>
  </xsl:function>
  
  <xsl:function name="math:sin" use-when="not(function-available('math:sin'))" as="xs:double">
    <xsl:param name="x" as="xs:double"/>
    <xsl:variable name="precision" select="20" as="xs:integer"/>
    <xsl:variable name="xx" select="$x"/>
    <xsl:variable name="pipi" select="2 * math:pi()" as="xs:double"/>
    
    <!-- improve accuracy by scaling $xx to less than PI -->
    <xsl:choose>
      <xsl:when test="$xx &gt; $pipi">
        <xsl:variable name="xx" select="$x - floor($x div $pipi) * $pipi"/>
        <xsl:sequence select="sum(internal:sin-taylor-series($xx, $precision, 1)) - sum(internal:sin-taylor-series($xx, $precision, 3))"/>
      </xsl:when>
      <xsl:when test="$xx &lt; -$pipi">
        <xsl:variable name="xx" select="$x - ceiling($x div $pipi) * $pipi"/>
        <xsl:sequence select="sum(internal:sin-taylor-series($xx, $precision, 1)) - sum(internal:sin-taylor-series($xx, $precision, 3))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="sum(internal:sin-taylor-series($xx, $precision, 1)) - sum(internal:sin-taylor-series($xx, $precision, 3))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="math:pi" use-when="not(function-available('math:pi'))" as="xs:double">
    <xsl:sequence select="3.14159265358979323846264338327950288419716939937510"/>
  </xsl:function>

  <xsl:function name="internal:sin-taylor-series" use-when="not(function-available('math:sin'))" as="xs:double*">
    <xsl:param name="x" as="xs:double"/>
    <xsl:param name="d" as="xs:integer"/>
    <xsl:param name="offset" as="xs:integer"/>
    <xsl:variable name="f" select="$offset + 2 * $d" as="xs:integer"/>
    <xsl:variable name="y" select="math:pow($x, $f) div internal:factorial($f)" as="xs:double"/>
    <xsl:sequence select="if ($d &gt; 1) then ($y, internal:sin-taylor-series($x, $d - 2, $offset)) else ($y)"/>
  </xsl:function>
  
  <xsl:function name="internal:factorial" use-when="not(function-available('math:sin'))" as="xs:integer">
    <xsl:param name="x" as="xs:integer"/>
    <xsl:sequence select="internal:factorial($x, $x)"/>
  </xsl:function>

  <xsl:function name="internal:factorial" use-when="not(function-available('math:sin'))" as="xs:integer">
    <xsl:param name="x" as="xs:integer"/>
    <xsl:param name="d" as="xs:integer"/>
    <xsl:sequence select="if ($d &gt; 2) then $d * internal:factorial($x, $d - 1) else $d"/>
  </xsl:function>

  <xsl:function name="math:pow" use-when="not(function-available('math:pow'))" as="xs:double">
    <xsl:param name="x" as="xs:double"/>
    <xsl:param name="d" as="xs:integer"/> <!-- TODO: support xs:double and negative numbers -->
    <xsl:sequence select="internal:pow($x, abs($d))"/>
  </xsl:function>

  <xsl:function name="internal:pow" use-when="not(function-available('math:pow'))" as="xs:double">
    <xsl:param name="x" as="xs:double"/>
    <xsl:param name="d" as="xs:integer"/>
    <xsl:sequence select="if ($d = 1) then $x else if ($d = 0) then 0 else $x * internal:pow($x, $d - 1)"/>
  </xsl:function>
  
  <xsl:function name="math:sqrt" as="xs:double">
    <xsl:param name="x" as="xs:double"/>
    <xsl:call-template name="sqrt">
      <xsl:with-param name="num" select="$x"/>
    </xsl:call-template>
  </xsl:function>
  
  <!-- sqrt implementation from <http://www.stylusstudio.com/xsllist/200108/post40740.html> -->
  <xsl:template name="sqrt" use-when="not(function-available('math:sqrt'))">
    <xsl:param name="num" select="0"/>  <!-- The number you want to find the
  square root of -->
    <xsl:param name="try" select="1"/>  <!-- The current 'try'.  This is used
  internally. -->
    <xsl:param name="iter" select="1"/> <!-- The current iteration, checked
  against maxiter to limit loop count -->
    <xsl:param name="maxiter" select="10"/>  <!-- Set this up to insure
  against infinite loops -->

    <!-- This template was written by Nate Austin using Sir Isaac Newton's
  method of finding roots -->

    <xsl:choose>
      <xsl:when test="$try * $try = $num or $iter &gt; $maxiter">
        <xsl:sequence select="$try"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="sqrt">
          <xsl:with-param name="num" select="$num"/>
          <xsl:with-param name="try" select="$try - (($try * $try - $num) div
  (2 * $try))"/>
          <xsl:with-param name="iter" select="$iter + 1"/>
          <xsl:with-param name="maxiter" select="$maxiter"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>