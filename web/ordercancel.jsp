<%@page import="db.OrderDB"%>
<%@page import="common.*"%>
<%@page import="beans.*"%>
<%@page import="java.util.*"%>


<jsp:include page="layout_top.jsp" />
<jsp:include page="layout_header.jsp" />
<%
    String errmsg = "";
    Helper helper = new Helper(request);
    helper.setCurrentPage(Constants.CURRENT_PAGE_MYORDER);
    if(!helper.isLoggedin()){
        session.setAttribute(Constants.SESSION_LOGIN_MSG, "Porfavor iniciar sesión!");
        response.sendRedirect("account_login.jsp");
        return;
    }
    
    String orderid = request.getParameter("orderid");
    if (orderid==null||orderid.isEmpty()) {
        errmsg = "¡Parámetro no válido! La identificación del pedido está vacía!";
    }

    if (errmsg.isEmpty()) {
        List<Order> orders = OrderDB.getList();
        synchronized(session) {
            if (orders == null || orders.size() == 0) {
                errmsg = "No tienes pedidos!";
            } else {
                Order order = OrderDB.getOrder(Integer.parseInt(orderid));
                if (order == null) {
                    errmsg = "El pedido ["+orderid+"] no se encontró!";
                } else {                    
                    List<OrderItem> items = order.getItems();
                    for (OrderItem item: items) {
                        if (item.getProductType() == 4 || item.getProductType() == 5) {
                            Date deliverydate = order.getDeliveryDate();
                            Calendar c = Calendar.getInstance();
                            c.setTime(deliverydate);
                            c.add(Calendar.DATE, -5);
                            Date now = new Date();
                            int comparison = now.compareTo(c.getTime());
                            if (comparison > 0) {
                                errmsg = "The order can only be cancelled within 5 days before delivery date ["+helper.formateDate(order.getDeliveryDate())+"]"
                                        + "<br><h2 style=\"color:red;\">You can't cancel it now.</h2>";
                            }
                        }
                    }
                }
            }
            if (errmsg.isEmpty()) {
                OrderDB.delete(Integer.parseInt(orderid));
                errmsg = "El pedido ["+orderid+"] ha sido eliminado!";
            }
        }
    }
    pageContext.setAttribute("errmsg", errmsg);
%>
<jsp:include page="layout_menu.jsp" />
<section id='content'>
    <div class='cart'>
        <h3>Cancelar Pedido</h3>
        <h3 style='color:red'>${errmsg}</h3>
    </div>
</section>
<jsp:include page="layout_sidebar.jsp" />
<jsp:include page="layout_footer.jsp" />