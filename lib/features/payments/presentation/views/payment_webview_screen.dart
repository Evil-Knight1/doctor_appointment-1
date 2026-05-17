import 'package:doctor_appointment/core/theme/app_theme_extension.dart';
import 'package:doctor_appointment/features/payments/logic/payment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders the Paymob payment iframe inside an in-app WebView.
///
/// Paymob sends the user to either:
///   - Success callback: URL contains `success=true`
///   - Pending/failure callback: URL contains `success=false` or `pending=true`
///
/// We intercept those redirects here and call [PaymentCubit.onWebViewResult].
/// The WebView callback is NOT the source of truth — it triggers backend polling.
class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final PaymentCubit cubit;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.cubit,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _resultReported = false;

  // Paymob's callback URL patterns to intercept.
  static const _successPattern = 'success=true';
  static const _failurePattern = 'success=false';
  static const _pendingPattern = 'pending=true';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            // Only report if we haven't already captured a result.
            if (!_resultReported) {
              _reportResult(success: false, failureReason: error.description);
            }
          },
          onNavigationRequest: (request) {
            return _handleNavigationRequest(request);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final url = request.url.toLowerCase();

    if (_resultReported) return NavigationDecision.prevent;

    // Detect Paymob success callback.
    if (url.contains(_successPattern)) {
      final transactionId = Uri.parse(request.url)
          .queryParameters['id'];
      _reportResult(success: true, providerTransactionId: transactionId);
      return NavigationDecision.prevent;
    }

    // Detect Paymob failure/cancellation callback.
    if (url.contains(_failurePattern) || url.contains(_pendingPattern)) {
      final reason = Uri.parse(request.url)
          .queryParameters['txn_response_code'];
      _reportResult(success: false, failureReason: reason);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  void _reportResult({
    required bool success,
    String? providerTransactionId,
    String? failureReason,
  }) {
    if (_resultReported) return;
    _resultReported = true;

    widget.cubit.onWebViewResult(
      success: success,
      providerTransactionId: providerTransactionId,
      failureReason: failureReason,
    );

    // Pop the WebView — the parent BlocConsumer handles navigation.
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurface,
            size: 24.sp,
          ),
          tooltip: 'Cancel Payment',
          onPressed: () {
            if (!_resultReported) {
              _reportResult(success: false, failureReason: 'User cancelled');
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Secure Payment',
          style: context.styleSemiBold16.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          // SSL padlock indicator
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Icon(
              Icons.lock_rounded,
              color: colorScheme.primary,
              size: 18.sp,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: colorScheme.primary),
                    SizedBox(height: 16.h),
                    Text(
                      'Loading secure payment…',
                      style: context.styleRegular14.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
