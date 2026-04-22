package Package1 {
	view view1 : StandardViewDefinitions::ActionFlowView {
		expose Parts::Part::start;
		expose Parts::Part::done;
		expose action1;
		expose action1::forkNode1;
		expose action1::action3;
		expose action1::action2;
	}
	action action1 {
		fork forkNode1;
		action action3;
		action action2;
		first start then forkNode1;
		first forkNode1 then action2;
		first forkNode1 then action3;
		first action2 then done;
		first action3 then done;
	}
}