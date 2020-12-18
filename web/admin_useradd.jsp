<%@page import="common.*"%>
<%@page import="dao.UserDao"%>
<%@page import="beans.User"%>


<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
    String currentusertype = helper.usertype();
    String errmsg = "";
    if (currentusertype == null || !currentusertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
        errmsg = "No tienes autorización para gestionar usuarios!";
    }

    User user = null;

    if (errmsg.isEmpty()) {
        if ("GET".equalsIgnoreCase(request.getMethod())) {
            user = new User("Name1", "123456", "customer");
        } else {
            String name = request.getParameter("name");
            String password = request.getParameter("password");
            String usertype = request.getParameter("usertype");

            if (name == null) {
                errmsg = "El nombre no puede estar vacío!";
            } else if (password == null) {
                errmsg = "La contraseña no puede estar vacía!";
            } else if (usertype == null) {
                errmsg = "El tipo de usuario no puede estar vacío!";
            }

            user = new User(name, password, usertype);
            if (errmsg.isEmpty()) {
                UserDao dao = UserDao.createInstance();
                if (dao.isExisted(name)) {
                    errmsg = "El usuario [" + name + "] ya existe!";
                } else {
                    dao.addUser(user);
                    errmsg = "E usuario [" + name + "] fué creado!";
                }
            }
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
    pageContext.setAttribute("list", helper.getUserTypeList());
    pageContext.setAttribute("user", user);
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div>
        <h3>Añadir Usuario</h3>
        <h3 style='color:red'>${errmsg}</h3>
        <form action="admin_useradd.jsp" method="Post">
            <table style='width:50%'>
                <tr><td><h5>Tipo de Usuario:</h5></td>
                    <td>
                        <select name='usertype' class='input'>
                            <c:forEach var="option" items="${list}">
                                <c:choose>
                                    <c:when test="${option.key == user.usertype.toLowerCase()}">
                                        <option value=${option.key} selected>${option.text}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value=${option.key}>${option.text}</option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>  
                        </select>
                    </td>
                </tr>
                <tr><td><h5>Nombres:</h5></td><td><input type='text' name='name' value='${user.name}' class='input' required /></td></tr>
                <tr><td><h5>Pass:</h5></td><td><input type='text' name='password' value='${user.password}' class='input' required /></td></tr>
                <tr><td colspan="2"><input name="create" class="formbutton" value="Crear" type="submit" /></td></tr>
            </table>
        </form>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />