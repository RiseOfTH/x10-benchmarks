package bcg;

public class BCTaskItem {
	public var startVertexIdx:Int = 0n;
	public var endVertexIdx:Int = 0n;
	public def this(s:Int, e:Int){
		this.startVertexIdx = s;
		this.endVertexIdx = e;
	}
}
