<%@page import="db.OrderDB"%>
<%@page import="common.*"%>

<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_USERMNG);
    if (!helper.isLoggedin()) {
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesi�n!");
        response.sendRedirect("account_login.jsp");
        return;
    }
    String usertype = helper.usertype();
    String errmsg = "";
    if (usertype == null || !usertype.equals(Constants.CONST_TYPE_SALESMAN_LOWER)) {
        errmsg = "No tienes autorizaci�n para administrar usuarios!";
    }

    if (errmsg.isEmpty()) {
        String orderid = request.getParameter("orderid");

        if (orderid == null || orderid.isEmpty()) {
            errmsg = "Par�metros no v�lidos!";
        } else {
            int id = Integer.parseInt(orderid);
            if (OrderDB.exists(id)) {
                OrderDB.delete(id);
                response.sendRedirect("admin_orderlist.jsp");
            } else {
                errmsg = "No se encontr� ning�n pedido!";
            }
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
%>
<jsp:include page="layout_menu.jsp" />
<section id="content">
    <div>
        <h3>Eliminar Usuario</h3>
        <h3 style='color:red'>${errmsg}</h3>    
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />
