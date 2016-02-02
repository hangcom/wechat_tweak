#import "Pay/CMessageNodeData.h"
#import "Pay/CMessageWrap.h"
#import "Pay/WCPayC2CMessageNodeView.h"
#import "Pay/BaseMsgContentViewController.h"

%hook BaseMsgContentViewController

- (id)newMessageNodeViewForMessageWrap:(id)arg1 contact:(id)arg2 chatContact:(id)arg3
{
    //NSLog(@"newMessageNodeViewForMessageWrap %@ %@", [arg1 class], [NSThread callStackSymbols]);
    id msg = %orig;
    [self performSelector:@selector(checkRedEnvelope:) withObject:arg1 afterDelay:1];
    return msg;
}

%new
- (void)checkRedEnvelope:(CMessageWrap *)msg
{
    if ([msg m_uiMessageType] == 49) {
        CMessageNodeData *node = [self findNodeDataByLocalId:[msg m_uiMesLocalID]];
        if (node && [NSStringFromClass([[node m_view] class]) isEqualToString:@"WCPayC2CMessageNodeView"]) {
            WCPayC2CMessageNodeView *view = (WCPayC2CMessageNodeView *)[node m_view];
            [view onClick];
        }
    }
}

%end


%hook WCRedEnvelopesReceiveHomeView

- (id)initWithFrame:(struct CGRect)arg1 andData:(id)arg2 delegate:(id)arg3
{
    [self performSelector:@selector(OnOpenRedEnvelopes) withObject:nil afterDelay:1];
    return %orig;
}

- (void)OnOpenRedEnvelopes
{
    %orig;
    [self performSelector:@selector(OnCancelButtonDone) withObject:nil afterDelay:1];
}

%end


%hook WCRedEnvelopesReceiveControlLogic

- (void)OnReceiverQueryRedEnvelopesRequest:(id)arg1 Error:(id)arg2
{
    NSLog(@"OnReceiverQueryRedEnvelopesRequest %@ %@", arg1, [NSThread callStackSymbols]);
    %orig;
}

- (void)showSuccessOpenAnimation
{
    NSLog(@"showSuccessOpenAnimation %@", [NSThread callStackSymbols]);
    %orig;
    [self performSelector:@selector(dismissCurrentViewSendShareRedEnvelopes) withObject:nil afterDelay:1];
}

%end