<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="common.*" %>
<%
    String username = "";
    if (session.getAttribute(Constants.SESSION_USERNAME) != null) {
        username = session.getAttribute(Constants.SESSION_USERNAME).toString();
        username = Character.toUpperCase(username.charAt(0)) + username.substring(1);
    }
    request.setAttribute("username", username);
%>
<header>
    <div class="header_logo">
        <table>
            <tr>
                <td><img src="images/site/logo_1.png" alt="" /></td>
                <td><h1><a href="index.jsp">SKRGame <span>Store</span></a></h1></td>
            </tr>
        </table>
    </div>
    <div class="header_right">
        <div class="account">
            <ul>
                <c:choose>
                    <c:when test="${not empty username}">
                        <li>Hola, ${username}</li>
                        <li><a href='account_logout.jsp'>Cerrar Sesion</a></li>
                        </c:when>
                        <c:otherwise>
                        <li><a href='account_register.jsp'>Registro</a></li>
                        <li><a href='account_login.jsp'>Login</a></li>
                        </c:otherwise>
                    </c:choose>
            </ul>
        </div>
        <div class="clear"></div>
        <div class="header_search">
            <form action="searchproduct.jsp" method="Post">
                <input type="text" id="search" name="productname" value="" placeholder="buscar...">
                <input type="submit" value="">
            </form>
        </div>
    </div>
</header>
<div class="clear"></div>
