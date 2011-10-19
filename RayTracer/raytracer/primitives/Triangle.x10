package raytracer.primitives;

import raytracer.*;

public final class Triangle extends Primitive {
    val p1:Vector3;
    val e1:Vector3, e2:Vector3;
    public def this (p1:Vector3, p2:Vector3, p3:Vector3) {
        this.p1 = p1;
        this.e1 = p2 - p1;
        this.e2 = p3 - p1;
    }
    public def getAABB() = AABB(Vector3.min(p1,Vector3.min(p1+e1, p1+e2)), Vector3.max(p1,Vector3.max(p1+e1, p1+e2)));
    public def intersectRay (st:RayState) : Boolean {
        // Stolen from http://www.lighthouse3d.com/tutorials/maths/ray-triangle-intersection/
        val h = st.d.cross(e2);
        val a = e1.dot(h);

        if (a > -0.00001 && a < 0.00001)
            return false;

        val f = 1/a;
        val s = st.o - p1;
        val u = f * s.dot(h);

        if (u < 0.0 || u > 1.0)
            return false;

        val q = s.cross(e1);
        val v = f * st.d.dot(q);

        if (v < 0.0 || u + v > 1.0)
            return false;

        // at this stage we can compute t to find out where
        // the intersection point is on the line
        val t = f * e2.dot(q);

        // line intersection but not ray intersection
        if (t < 0.00001) return false;

        st.t = t;
        st.normal = e1.cross(e2);
        return true;
    }
}
