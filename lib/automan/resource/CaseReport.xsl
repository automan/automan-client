<?xml version="1.0" encoding="gb2312"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
  <html>
    <body>
    <h2>AutoMan脚本运行日志</h2>
    <xsl:for-each select="TestRun">
    <h3>脚本名称：<xsl:value-of select="./@scriptName"/></h3>
    <table border="1">
    <tr>
      <td><b>类型</b></td>
      <td><b>信息</b></td>
    </tr>
    <xsl:for-each select="Trace|TestResult">
    <tr>
      <xsl:choose>
      <xsl:when test="string(@type)='start'">
      <td style="background:HoneyDew"><xsl:value-of select="./@type"/>[<xsl:value-of select="./@id"/>]</td>
      <td style="background:HoneyDew">[<xsl:value-of select="./@title"/>][<xsl:value-of select="./@time"/>]</td>
      </xsl:when>
      <xsl:when test="string(@type)='end'">
      <xsl:choose>
      <xsl:when test="string(./@result)='Success'">
      <td style="background:Lime"><xsl:value-of select="./@type"/>[<xsl:value-of select="./@id"/>]</td>
      <td style="background:Lime"><xsl:value-of select="./@result"/>[<xsl:value-of select="./@title"/>][<xsl:value-of select="./@time"/>]</td>
      </xsl:when>
      <xsl:otherwise>
      <td style="background:red"><xsl:value-of select="./@type"/>[<xsl:value-of select="./@id"/>]</td>
      <td style="background:red"><xsl:value-of select="./@result"/>[<xsl:value-of select="./@title"/>][<xsl:value-of select="./@time"/>]</td>
      </xsl:otherwise>
      </xsl:choose>
      </xsl:when>
      <xsl:when test="string(@type)='BackTrace'">
      <td><xsl:value-of select="./@type"/></td>
      <td><pre><xsl:value-of select="."/></pre></td>
      </xsl:when>
      <xsl:otherwise>
      <td><xsl:value-of select="./@type"/></td>
      <td><xsl:value-of select="."/></td>
      </xsl:otherwise>
      </xsl:choose>
    </tr>
    </xsl:for-each>
    </table>
    </xsl:for-each>
  </body>
  </html>
</xsl:template>

</xsl:stylesheet>