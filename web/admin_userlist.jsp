<%@page import="common.*"%>
<%@page import="java.util.List"%>
<%@page import="dao.UserDao"%>
<%@page import="beans.User"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_USERMNG);
    if (!helper.isLoggedin()) {
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesión!");
        response.sendRedirect("account_login.jsp");
        return;
    }

    String usertype = helper.usertype();
    String errmsg = "";
    if (usertype == null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
        errmsg = "No tienes autorización para gestionar usuarios!";
    } else {
        UserDao dao = UserDao.createInstance();
        List<User> list = dao.getUserList();
        pageContext.setAttribute("list", list);
    }
    pageContext.setAttribute("errmsg", errmsg);
%>
<jsp:include page="layout_menu.jsp" />
<section id='content'>
    <div class='cart'>
        <h3>Lista de Usuarios</h3>
        <c:choose>
            <c:when test="${not empty errmsg}">
                <h3 style='color:red'>${errmsg}</h3>
            </c:when>
            <c:otherwise>
                <c:set var="counter" value="0" scope="page" />
                <div style='padding:5px'><a href='admin_useradd.jsp' class='button'>Crear Nuevo Usuario</a></div>
                <table cellspacing='0'>
                    <tr><th>No.</th><th>Nom. Usuario</th><th>Tipo de Usuario</th><th>Acción</th></tr>           
                            <c:forEach var="user" items="${list}">
                        <tr>
                            <td><c:out value="${counter + 1}"/></td><td><c:out value="${user.name}"/></td><td><c:out value="${user.usertype}"/></td>
                            <td>
                                <span style='padding-right:3px;'><a href='admin_useredit.jsp?usertype=<c:out value="${user.usertype}"/>&name=<c:out value="${user.name}"/>' class='button'>Editar</a></span>
                                <span><a href='admin_userdel.jsp?username=<c:out value="${user.name}"/>' class='button' onclick = "return confirm('¿Estás seguro de eliminar a este usuario?')">Eliminar</a></span>
                            </td>
                        </tr>
                        <c:set var="counter" value="${counter + 1}" scope="page"/>
                    </c:forEach>               
                </table>
            </c:otherwise>
        </c:choose>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />