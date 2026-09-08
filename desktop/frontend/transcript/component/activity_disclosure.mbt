///|
/// The expanded lead occupies the preview's position but stays outside the
/// summary's accessible name. Forward ordinary clicks to the native disclosure;
/// selecting evidence or activating Markdown controls must keep it open.
extern "js" fn collapse_activity_from_text(event : @dom.MouseEvent) -> Unit =
  #| event => {
  #|   if (event.defaultPrevented || event.button !== 0 ||
  #|       event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
  #|   const lead = event.currentTarget;
  #|   const target = event.target;
  #|   if (target.closest('a, button, input, textarea, select, summary, [role="button"], [contenteditable]')) return;
  #|   const selection = lead.ownerDocument.getSelection();
  #|   if (selection && !selection.isCollapsed && selection.containsNode(lead, true)) return;
  #|   const summary = lead.parentElement.querySelector(':scope > summary');
  #|   summary.focus({ preventScroll: true });
  #|   summary.click();
  #| }
